package com.example.direcao_financeira_mobile.parsers

import android.view.accessibility.AccessibilityNodeInfo
import java.text.Normalizer

class MoveSjParser {

    private val priceRegex = Regex("R\\$\\s*\\d+(?:[.,]\\d+)?")
    private val ratingRegex =
        Regex("\\d+(?:[.,]\\d+)?\\s*[\\u2605\\u2B50]", RegexOption.IGNORE_CASE)
    private val routeStepRegex =
        Regex("\\d+(?:[.,]\\d+)?\\s*km\\s*\\(\\d+\\s*min\\)", RegexOption.IGNORE_CASE)
    private val offerDistanceRegex =
        Regex(
            "(\\d+(?:[.,]\\d+)?)\\s*km\\s*\\(\\s*R\\$\\s*\\d+(?:[.,]\\d+)?\\s*/\\s*km\\s*\\)",
            RegexOption.IGNORE_CASE,
        )
    private val offerMinutesRegex =
        Regex(
            "(\\d+)\\s*min\\s*\\(\\s*R\\$\\s*\\d+(?:[.,]\\d+)?\\s*/\\s*min\\s*\\)",
            RegexOption.IGNORE_CASE,
        )
    private val actionMarkers =
        listOf(
            "deslize para recusar",
            "deslize para aceitar",
            "recusar",
            "aceitar",
        )

    fun isOfferScreen(rootNode: AccessibilityNodeInfo): Boolean {
        return isOfferScreenFromLines(collectVisibleTexts(rootNode))
    }

    fun buildScreenFingerprint(rootNode: AccessibilityNodeInfo): String {
        val lines = collectVisibleTexts(rootNode)
        val priceText = findNodeByRegex(rootNode, priceRegex)?.text?.toString() ?: ""
        val parsedOffer = extractOfferDetails(lines)

        return listOf(
            "MoveSj",
            normalizeFingerprintValue(priceText),
            normalizeFingerprintValue(parsedOffer.metrics.totalKm.toString()),
            normalizeFingerprintValue(parsedOffer.metrics.totalMinutes.toString()),
            normalizeFingerprintValue(parsedOffer.passengerName),
            normalizeFingerprintValue(parsedOffer.originAddress),
            normalizeFingerprintValue(parsedOffer.destinationAddress),
        ).joinToString("|")
    }

    fun parseOffer(rootNode: AccessibilityNodeInfo): Map<String, Any> {
        val lines = collectVisibleTexts(rootNode)
        val priceNode = findNodeByRegex(rootNode, priceRegex)
        val ratingNode = findNodeByRegex(rootNode, ratingRegex)
        return parseOfferFromLines(
            lines = lines,
            priceText = priceNode?.text?.toString() ?: "R$ 0,00",
            ratingText = ratingNode?.text?.toString(),
        )
    }

    internal fun parseOfferFromLines(
        lines: List<String>,
        priceText: String = "R$ 0,00",
        ratingText: String? = null,
    ): Map<String, Any> {
        val parsedOffer = extractOfferDetails(lines)

        return mutableMapOf<String, Any>(
            "app" to "MoveSj",
            "platform_name" to "MoveSj",
            "valor_bruto" to priceText,
            "km_total" to parsedOffer.metrics.totalKm,
            "minutos_total" to parsedOffer.metrics.totalMinutes,
            "avaliacao" to sanitizeRating(ratingText),
            "passenger_name" to (parsedOffer.passengerName ?: ""),
            "origin_address" to (parsedOffer.originAddress ?: ""),
            "destination_address" to (parsedOffer.destinationAddress ?: ""),
        )
    }

    internal fun isOfferScreenFromLines(lines: List<String>): Boolean {
        val normalizedLines = normalizeVisibleTexts(lines)
        val hasMainPrice = normalizedLines.any { priceRegex.containsMatchIn(it) }
        val hasMetrics =
            normalizedLines.any { offerDistanceRegex.containsMatchIn(it) } &&
                normalizedLines.any { offerMinutesRegex.containsMatchIn(it) }
        val hasActionMarker =
            normalizedLines.any { line ->
                val normalized = normalizedText(line)
                actionMarkers.any { marker -> normalized.contains(marker) }
            }

        return hasMainPrice && hasMetrics && hasActionMarker
    }

    private fun extractOfferDetails(lines: List<String>): MoveSjParsedOffer {
        val normalizedLines = normalizeVisibleTexts(lines)
        val passengerName = extractPassengerName(normalizedLines)
        val addresses = extractAddresses(normalizedLines, passengerName)
        val offerMetrics = extractOfferMetrics(normalizedLines)

        return MoveSjParsedOffer(
            passengerName = passengerName,
            originAddress = addresses.first,
            destinationAddress = addresses.second,
            metrics = offerMetrics,
        )
    }

    private fun extractOfferMetrics(lines: List<String>): MoveSjOfferMetrics {
        var totalKm = 0.0
        var totalMinutes = 0

        lines.forEach { line ->
            if (totalKm <= 0) {
                val kmValue =
                    offerDistanceRegex.find(line)
                        ?.groupValues
                        ?.getOrNull(1)
                        ?.replace(",", ".")
                        ?.toDoubleOrNull()
                if (kmValue != null && kmValue > 0) {
                    totalKm = kmValue
                }
            }

            if (totalMinutes <= 0) {
                val minuteValue =
                    offerMinutesRegex.find(line)
                        ?.groupValues
                        ?.getOrNull(1)
                        ?.toIntOrNull()
                if (minuteValue != null && minuteValue > 0) {
                    totalMinutes = minuteValue
                }
            }
        }

        if (totalKm <= 0 || totalMinutes <= 0) {
            lines.forEach { line ->
                val routeMatch = routeStepRegex.find(line) ?: return@forEach
                val routeText = routeMatch.value

                if (totalKm <= 0) {
                    val routeKm =
                        Regex("(\\d+(?:[.,]\\d+)?)\\s*km", RegexOption.IGNORE_CASE)
                            .find(routeText)
                            ?.groupValues
                            ?.getOrNull(1)
                            ?.replace(",", ".")
                            ?.toDoubleOrNull()
                    if (routeKm != null) {
                        totalKm += routeKm
                    }
                }

                if (totalMinutes <= 0) {
                    val routeMinutes =
                        Regex("\\((\\d+)\\s*min\\)", RegexOption.IGNORE_CASE)
                            .find(routeText)
                            ?.groupValues
                            ?.getOrNull(1)
                            ?.toIntOrNull()
                    if (routeMinutes != null) {
                        totalMinutes += routeMinutes
                    }
                }
            }
        }

        return MoveSjOfferMetrics(totalKm = totalKm, totalMinutes = totalMinutes)
    }

    private fun collectVisibleTexts(rootNode: AccessibilityNodeInfo): List<String> {
        return normalizeVisibleTexts(collectNonEmptyTexts(rootNode))
    }

    private fun normalizeVisibleTexts(lines: List<String>): List<String> {
        val normalizedLines = mutableListOf<String>()

        lines.forEach { rawLine ->
            val trimmed = rawLine.trim()
            if (trimmed.isEmpty()) {
                return@forEach
            }

            if (normalizedLines.lastOrNull() == trimmed) {
                return@forEach
            }

            normalizedLines.add(trimmed)
        }

        return normalizedLines
    }

    private fun extractPassengerName(lines: List<String>): String? {
        val ratingIndex = lines.indexOfFirst { ratingRegex.containsMatchIn(it) }
        if (ratingIndex >= 0) {
            for (index in (ratingIndex - 1).coerceAtLeast(0) downTo (ratingIndex - 3).coerceAtLeast(0)) {
                val candidate = lines[index]
                if (isPassengerCandidate(candidate)) {
                    return candidate
                }
            }
        }

        lines.firstOrNull(::isPassengerCandidate)?.let { return it }
        return null
    }

    private fun isPassengerCandidate(line: String): Boolean {
        val normalized = normalizedText(line)
        return line.length in 3..30 &&
            line.any { it.isLetter() } &&
            !normalized.contains("deslize") &&
            !normalized.contains("km") &&
            !normalized.contains("min") &&
            !normalized.contains("r$") &&
            !normalized.contains("aceitar") &&
            !normalized.contains("recusar") &&
            !normalized.contains("pix") &&
            !normalized.contains("cartao") &&
            !normalized.contains("dinheiro") &&
            !normalized.contains("move") &&
            !normalized.contains("movesj") &&
            !normalized.contains("app") &&
            !normalized.contains("corrida") &&
            !normalized.contains("motorista") &&
            !normalized.contains("sao joao") &&
            !normalized.contains("centro") &&
            !ratingRegex.containsMatchIn(line)
    }

    private fun extractAddresses(
        lines: List<String>,
        passengerName: String?,
    ): Pair<String?, String?> {
        val routeAddresses = mutableListOf<String>()

        lines.forEachIndexed { index, line ->
            if (!routeStepRegex.containsMatchIn(line)) {
                return@forEachIndexed
            }

            val addressBlock =
                buildAddressBlock(
                    lines = lines,
                    startIndex = index + 1,
                    passengerName = passengerName,
                )
            if (addressBlock != null) {
                routeAddresses.add(addressBlock)
            }
        }

        val fallbackAddresses = buildFallbackAddressBlocks(lines, passengerName)
        val distinctAddresses = distinctAddressBlocks(routeAddresses + fallbackAddresses)

        return distinctAddresses.getOrNull(0) to distinctAddresses.getOrNull(1)
    }

    private fun buildAddressBlock(
        lines: List<String>,
        startIndex: Int,
        passengerName: String?,
    ): String? {
        val collected = mutableListOf<String>()

        for (index in startIndex until lines.size) {
            val candidate = lines[index]
            if (routeStepRegex.containsMatchIn(candidate)) {
                break
            }

            if (!isAddressCandidate(candidate, passengerName)) {
                if (collected.isNotEmpty()) {
                    break
                }
                continue
            }

            collected.add(candidate)

            // Endereco da MoveSj costuma vir quebrado em 1 a 3 linhas.
            if (collected.size >= 3) {
                break
            }
        }

        return joinAddressLines(collected)
    }

    private fun buildFallbackAddressBlocks(
        lines: List<String>,
        passengerName: String?,
    ): List<String> {
        val blocks = mutableListOf<String>()
        val currentBlock = mutableListOf<String>()

        fun flushCurrentBlock() {
            val addressBlock = joinAddressLines(currentBlock)
            if (addressBlock != null) {
                blocks.add(addressBlock)
            }
            currentBlock.clear()
        }

        for (line in lines) {
            if (routeStepRegex.containsMatchIn(line)) {
                flushCurrentBlock()
                continue
            }

            if (!isAddressCandidate(line, passengerName)) {
                flushCurrentBlock()
                continue
            }

            currentBlock.add(line)
            if (currentBlock.size >= 3) {
                flushCurrentBlock()
            }
        }

        flushCurrentBlock()
        return blocks
    }

    private fun distinctAddressBlocks(blocks: List<String>): List<String> {
        val distinctBlocks = mutableListOf<String>()
        val seen = mutableSetOf<String>()

        blocks.forEach { block ->
            val normalized = normalizedText(block).replace(" ", "")
            if (normalized.isBlank() || !seen.add(normalized)) {
                return@forEach
            }

            distinctBlocks.add(block)
        }

        return distinctBlocks
    }

    private fun joinAddressLines(lines: List<String>): String? {
        return lines
            .map { it.trim() }
            .filter { it.isNotEmpty() }
            .joinToString(separator = " ")
            .takeIf { it.isNotBlank() }
    }

    private fun isAddressCandidate(
        line: String,
        passengerName: String?,
    ): Boolean {
        val normalized = normalizedText(line)
        return line.length >= 10 &&
            line.any { it.isLetter() } &&
            (passengerName == null || normalized != normalizedText(passengerName)) &&
            !normalized.contains("move") &&
            !normalized.contains("movesj") &&
            !normalized.contains("deslize") &&
            !normalized.contains("aceitar") &&
            !normalized.contains("recusar") &&
            !normalized.contains("km") &&
            !normalized.contains("min") &&
            !normalized.contains("r$") &&
            !normalized.contains("pix") &&
            !normalized.contains("cartao") &&
            !normalized.contains("dinheiro") &&
            !normalized.contains("motorista") &&
            !ratingRegex.containsMatchIn(line)
    }

    private fun findNodeByRegex(
        node: AccessibilityNodeInfo,
        regex: Regex,
    ): AccessibilityNodeInfo? {
        val nodeText = node.text?.toString() ?: ""
        if (regex.containsMatchIn(nodeText)) {
            return node
        }

        for (i in 0 until node.childCount) {
            val found = findNodeByRegex(node.getChild(i) ?: continue, regex)
            if (found != null) {
                return found
            }
        }

        return null
    }

    private fun findAllNodesByRegex(
        node: AccessibilityNodeInfo,
        regex: Regex,
    ): List<AccessibilityNodeInfo> {
        val result = mutableListOf<AccessibilityNodeInfo>()
        val nodeText = node.text?.toString() ?: ""
        if (regex.containsMatchIn(nodeText)) {
            result.add(node)
        }

        for (i in 0 until node.childCount) {
            result.addAll(findAllNodesByRegex(node.getChild(i) ?: continue, regex))
        }

        return result
    }

    private fun collectNonEmptyTexts(
        node: AccessibilityNodeInfo,
        result: MutableList<String> = mutableListOf(),
    ): List<String> {
        val text = node.text?.toString()?.trim()
        if (!text.isNullOrEmpty()) {
            result.add(text)
        }

        for (index in 0 until node.childCount) {
            val child = node.getChild(index) ?: continue
            collectNonEmptyTexts(child, result)
        }

        return result
    }

    private fun normalizedText(value: String?): String {
        if (value.isNullOrBlank()) {
            return ""
        }

        val normalized =
            Normalizer.normalize(value, Normalizer.Form.NFD)
                .replace("\\p{InCombiningDiacriticalMarks}+".toRegex(), "")

        return normalized.lowercase()
    }

    private fun normalizeFingerprintValue(value: String?): String {
        return normalizedText(value).replace(" ", "")
    }

    private fun sanitizeRating(ratingText: String?): String {
        return ratingText
            ?.replace("\u2605", "")
            ?.replace("\u2B50", "")
            ?.trim()
            ?.takeIf { it.isNotEmpty() }
            ?: "5,00"
    }

    private data class MoveSjOfferMetrics(
        val totalKm: Double,
        val totalMinutes: Int,
    )

    private data class MoveSjParsedOffer(
        val passengerName: String?,
        val originAddress: String?,
        val destinationAddress: String?,
        val metrics: MoveSjOfferMetrics,
    )
}
