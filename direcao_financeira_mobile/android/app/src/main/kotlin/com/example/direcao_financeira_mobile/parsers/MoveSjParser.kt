package com.example.direcao_financeira_mobile.parsers

import android.view.accessibility.AccessibilityNodeInfo
import java.text.Normalizer

class MoveSjParser {

    private val priceRegex = Regex("R\\$\\s*\\d+(?:[.,]\\d+)?")
    private val kmTimeRegex =
        Regex("\\d+(?:[.,]\\d+)?\\s*km\\s*\\(\\d+\\s*min\\)", RegexOption.IGNORE_CASE)
    private val ratingRegex =
        Regex("\\d+(?:[.,]\\d+)?\\s*[\\u2605\\u2B50]", RegexOption.IGNORE_CASE)
    private val routeStepRegex =
        Regex("\\d+(?:[.,]\\d+)?\\s*km\\s*\\(\\d+\\s*min\\)", RegexOption.IGNORE_CASE)

    fun isOfferScreen(rootNode: AccessibilityNodeInfo): Boolean {
        return findNodeByText(rootNode, "Deslize para recusar") != null ||
            findNodeByText(rootNode, "Deslize para aceitar") != null
    }

    fun parseOffer(rootNode: AccessibilityNodeInfo): Map<String, Any> {
        val data = mutableMapOf<String, Any>()
        val lines = collectVisibleTexts(rootNode)
        val passengerName = extractPassengerName(lines)
        val addresses = extractAddresses(lines, passengerName)

        data["app"] = "MoveSj"
        data["platform_name"] = "MoveSj"

        val priceNode = findNodeByRegex(rootNode, priceRegex)
        data["valor_bruto"] = priceNode?.text?.toString() ?: "R$ 0,00"

        val kmTimeMatches = findAllNodesByRegex(rootNode, kmTimeRegex)
        var totalKm = 0.0
        var totalMin = 0

        kmTimeMatches.forEach { node ->
            val text = node.text?.toString().orEmpty()
            val kmValue =
                Regex("(\\d+(?:[.,]\\d+)?)")
                    .find(text)
                    ?.value
                    ?.replace(",", ".")
                    ?.toDoubleOrNull() ?: 0.0
            val minValue =
                Regex("\\((\\d+)")
                    .find(text)
                    ?.groupValues
                    ?.getOrNull(1)
                    ?.toIntOrNull() ?: 0

            totalKm += kmValue
            totalMin += minValue
        }

        data["km_total"] = totalKm
        data["minutos_total"] = totalMin

        val ratingNode = findNodeByRegex(rootNode, ratingRegex)
        data["avaliacao"] =
            ratingNode?.text
                ?.toString()
                ?.replace("\u2605", "")
                ?.replace("\u2B50", "")
                ?: "5,00"
        data["passenger_name"] = passengerName ?: ""
        data["origin_address"] = addresses.first ?: ""
        data["destination_address"] = addresses.second ?: ""

        return data
    }

    private fun collectVisibleTexts(rootNode: AccessibilityNodeInfo): List<String> {
        return collectNonEmptyTexts(rootNode)
            .map { it.trim() }
            .filter { it.isNotEmpty() }
            .distinct()
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

        if (routeAddresses.isNotEmpty()) {
            val distinctAddresses = routeAddresses.distinct()
            return distinctAddresses.getOrNull(0) to distinctAddresses.getOrNull(1)
        }

        val fallbackCandidates =
            lines.filter { isAddressCandidate(it, passengerName) }.distinct()
        return fallbackCandidates.getOrNull(0) to fallbackCandidates.getOrNull(1)
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

            // Endereco da MoveSj costuma vir em 1 ou 2 linhas.
            if (collected.size >= 2) {
                break
            }
        }

        return collected
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

    private fun findNodeByText(
        node: AccessibilityNodeInfo,
        text: String,
    ): AccessibilityNodeInfo? {
        if (node.text?.toString()?.contains(text, ignoreCase = true) == true) {
            return node
        }

        for (i in 0 until node.childCount) {
            val found = findNodeByText(node.getChild(i) ?: continue, text)
            if (found != null) {
                return found
            }
        }

        return null
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
}
