package com.example.direcao_financeira_mobile.parsers

import android.view.accessibility.AccessibilityNodeInfo
import java.text.Normalizer

class NinetyNineParser {

    private val priceRegex = Regex("R\\$\\s*\\d+(?:[.,]\\d+)?")
    private val statsRegex =
        Regex("\\d+\\s*min\\s*\\(\\d+(?:[.,]\\d+)?\\s*km\\)", RegexOption.IGNORE_CASE)
    private val corridasLineRegex =
        Regex("(\\d+(?:[.,]\\d+)?)\\s*(?:[\\u2022·•]|\\.)?\\s*(\\d+)\\s*corridas", RegexOption.IGNORE_CASE)
    private val ratingProfileLineRegex =
        Regex("(\\d+(?:[.,]\\d+)?)\\s*(?:[\\u2022·•]|\\.)\\s*perfil\\b", RegexOption.IGNORE_CASE)
    private val fallbackRatingRegex = Regex("\\b\\d(?:[.,]\\d{1,2})\\b")
    private val profileRegex =
        Regex("Perfil\\s+([A-Za-zÀ-ÿ]+(?:\\s+[A-Za-zÀ-ÿ]+)*)", RegexOption.IGNORE_CASE)

    fun isOfferScreen(rootNode: AccessibilityNodeInfo): Boolean {
        val hasMainPrice = findNodeByRegex(rootNode, priceRegex) != null
        val hasRouteStats = findAllNodesByRegex(rootNode, statsRegex).size >= 2
        val hasOfferMarkers =
            findNodeContaining(rootNode, "preco x") != null ||
                findNodeContaining(rootNode, "nao afeta a ta") != null ||
                findNodeContaining(rootNode, "perfil") != null ||
                findNodeContaining(rootNode, "aceitar por") != null

        return hasMainPrice && (hasRouteStats || hasOfferMarkers)
    }

    fun buildScreenFingerprint(rootNode: AccessibilityNodeInfo): String {
        val lines = collectVisibleTexts(rootNode)
        val passengerName = extractPassengerName(lines)
        val addresses = extractAddresses(lines, passengerName)
        val priceText = findNodeByRegex(rootNode, priceRegex)?.text?.toString() ?: ""
        val statsMatches = findAllNodesByRegex(rootNode, statsRegex)
        var totalKm = 0.0
        var totalMin = 0

        statsMatches.forEach { node ->
            val text = node.text?.toString().orEmpty()
            val minValue =
                Regex("(\\d+)\\s*min", RegexOption.IGNORE_CASE)
                    .find(text)
                    ?.groupValues
                    ?.get(1)
                    ?.toIntOrNull() ?: 0
            val kmValue =
                Regex("\\((\\d+(?:[.,]\\d+)?)\\s*km", RegexOption.IGNORE_CASE)
                    .find(text)
                    ?.groupValues
                    ?.get(1)
                    ?.replace(",", ".")
                    ?.toDoubleOrNull() ?: 0.0

            totalKm += kmValue
            totalMin += minValue
        }

        return listOf(
            "99",
            normalizeFingerprintValue(priceText),
            normalizeFingerprintValue(totalKm.toString()),
            normalizeFingerprintValue(totalMin.toString()),
            normalizeFingerprintValue(passengerName),
            normalizeFingerprintValue(addresses.first),
            normalizeFingerprintValue(addresses.second),
        ).joinToString("|")
    }

    fun buildDebugSnapshot(rootNode: AccessibilityNodeInfo): Map<String, Any> {
        val priceNode = findNodeByRegex(rootNode, priceRegex)
        val statsMatches = findAllNodesByRegex(rootNode, statsRegex)
        val lines = collectVisibleTexts(rootNode)
        val rawText = lines.joinToString("\n")
        val passengerName = extractPassengerName(lines)
        val addresses = extractAddresses(lines, passengerName)

        return mapOf(
            "hasMainPrice" to (priceNode != null),
            "priceText" to (priceNode?.text?.toString() ?: ""),
            "statsCount" to statsMatches.size,
            "statsTexts" to statsMatches.map { it.text?.toString().orEmpty() },
            "offerType" to (extractOfferType(lines) ?: ""),
            "paymentMethod" to (extractPaymentMethod(lines) ?: ""),
            "rating" to (extractRating(rawText, lines) ?: ""),
            "ridesCount" to (extractRidesCount(rawText, lines) ?: 0),
            "passengerName" to (passengerName ?: ""),
            "originAddress" to (addresses.first ?: ""),
            "destinationAddress" to (addresses.second ?: ""),
            "sampleTexts" to lines.take(25),
        )
    }

    fun parseOffer(rootNode: AccessibilityNodeInfo): Map<String, Any> {
        val lines = collectVisibleTexts(rootNode)
        val rawText = lines.joinToString("\n")
        val passengerName = extractPassengerName(lines)
        val addresses = extractAddresses(lines, passengerName)

        val data = mutableMapOf<String, Any>()
        data["app"] = "99"
        data["platform_name"] = "99"

        val priceNode = findNodeByRegex(rootNode, priceRegex)
        data["valor_bruto"] = priceNode?.text?.toString() ?: "R$ 0,00"

        val statsMatches = findAllNodesByRegex(rootNode, statsRegex)
        var totalKm = 0.0
        var totalMin = 0

        statsMatches.forEach { node ->
            val text = node.text?.toString().orEmpty()
            val minValue =
                Regex("(\\d+)\\s*min", RegexOption.IGNORE_CASE)
                    .find(text)
                    ?.groupValues
                    ?.get(1)
                    ?.toIntOrNull() ?: 0
            val kmValue =
                Regex("\\((\\d+(?:[.,]\\d+)?)\\s*km", RegexOption.IGNORE_CASE)
                    .find(text)
                    ?.groupValues
                    ?.get(1)
                    ?.replace(",", ".")
                    ?.toDoubleOrNull() ?: 0.0

            totalKm += kmValue
            totalMin += minValue
        }

        data["km_total"] = totalKm
        data["minutos_total"] = totalMin
        data["avaliacao"] = extractRating(rawText, lines) ?: "5,00"
        data["corridas_total"] = extractRidesCount(rawText, lines) ?: 0
        data["passenger_name"] = passengerName ?: ""
        data["perfil_passageiro"] = passengerName ?: ""
        data["origin_address"] = addresses.first ?: ""
        data["destination_address"] = addresses.second ?: ""
        data["tipo_corrida"] = extractOfferType(lines) ?: ""
        data["forma_pagamento"] = extractPaymentMethod(lines) ?: ""

        return data
    }

    private fun collectVisibleTexts(rootNode: AccessibilityNodeInfo): List<String> {
        return collectNonEmptyTexts(rootNode)
            .map { it.removePrefix("cd:").trim() }
            .filter { it.isNotEmpty() }
            .distinct()
    }

    private fun extractPassengerName(lines: List<String>): String? {
        return lines.firstNotNullOfOrNull { line ->
            profileRegex.find(line)?.groupValues?.getOrNull(1)?.trim()
        }?.takeIf { it.isNotBlank() }
    }

    private fun extractAddresses(
        lines: List<String>,
        passengerName: String?,
    ): Pair<String?, String?> {
        val routeAnchoredAddresses = extractAddressesFromRouteStats(lines, passengerName)
        if (routeAnchoredAddresses.first != null || routeAnchoredAddresses.second != null) {
            return routeAnchoredAddresses
        }

        val candidates =
            lines.filter { isAddressCandidate(it, passengerName) }
                .distinct()

        return candidates.getOrNull(0) to candidates.getOrNull(1)
    }

    private fun extractAddressesFromRouteStats(
        lines: List<String>,
        passengerName: String?,
    ): Pair<String?, String?> {
        val addresses = mutableListOf<String>()

        lines.forEachIndexed { index, line ->
            if (!statsRegex.containsMatchIn(line)) {
                return@forEachIndexed
            }

            extractAddressFromStatLine(line, passengerName)?.let { address ->
                addresses.add(address)
                return@forEachIndexed
            }

            val nextAddress = findNextAddressCandidate(lines, startIndex = index + 1, passengerName = passengerName)
            if (nextAddress != null) {
                addresses.add(nextAddress)
            }
        }

        val distinctAddresses = addresses.distinct()
        return distinctAddresses.getOrNull(0) to distinctAddresses.getOrNull(1)
    }

    private fun extractAddressFromStatLine(
        line: String,
        passengerName: String?,
    ): String? {
        val match = statsRegex.find(line) ?: return null
        val candidate = line.substring(match.range.last + 1).trim()
        if (isAddressCandidate(candidate, passengerName)) {
            return candidate
        }

        return null
    }

    private fun findNextAddressCandidate(
        lines: List<String>,
        startIndex: Int,
        passengerName: String?,
    ): String? {
        for (index in startIndex until lines.size) {
            val currentLine = lines[index].trim()
            if (currentLine.isEmpty()) {
                continue
            }

            if (statsRegex.containsMatchIn(currentLine)) {
                return null
            }

            if (isAddressCandidate(currentLine, passengerName)) {
                return currentLine
            }
        }

        return null
    }

    private fun isAddressCandidate(
        line: String,
        passengerName: String?,
    ): Boolean {
        val trimmed = line.trim()
        val normalized = normalizedText(trimmed)

        if (trimmed.length < 6 || !trimmed.any { it.isLetter() }) {
            return false
        }

        if (passengerName != null && normalized == normalizedText(passengerName)) {
            return false
        }

        if (priceRegex.containsMatchIn(trimmed) || statsRegex.containsMatchIn(trimmed)) {
            return false
        }

        val blockedTerms =
            listOf(
                "preco x",
                "nao afeta a ta",
                "perfil",
                "corridas",
                "aceitar",
                "dinheiro",
                "pix",
                "cartao",
                "entrega",
                "negocia",
                "km",
                "min",
                "r$",
                "passageiro",
                "google",
                "maquina",
                "premium",
                "novo",
            )

        if (blockedTerms.any { normalized.contains(it) }) {
            return false
        }

        return true
    }

    private fun extractRating(
        rawText: String,
        lines: List<String>,
    ): String? {
        val corridasLine =
            lines.firstOrNull { normalizedText(it).contains("corridas") }
                ?: rawText.lineSequence().firstOrNull { normalizedText(it).contains("corridas") }

        if (!corridasLine.isNullOrBlank()) {
            corridasLineRegex.find(corridasLine)?.groupValues?.get(1)?.let { return it }
            fallbackRatingRegex.find(corridasLine)?.value?.let { return it }
        }

        val perfilLine =
            lines.firstOrNull { normalizedText(it).contains("perfil") }
                ?: rawText.lineSequence().firstOrNull { normalizedText(it).contains("perfil") }

        if (!perfilLine.isNullOrBlank()) {
            ratingProfileLineRegex.find(perfilLine)?.groupValues?.get(1)?.let { return it }
            fallbackRatingRegex.find(perfilLine)?.value?.let { return it }
        }

        return null
    }

    private fun extractRidesCount(
        rawText: String,
        lines: List<String>,
    ): Int? {
        val corridasLine =
            lines.firstOrNull { normalizedText(it).contains("corridas") }
                ?: rawText.lineSequence().firstOrNull { normalizedText(it).contains("corridas") }

        return corridasLine?.let { corridasLineRegex.find(it)?.groupValues?.get(2)?.toIntOrNull() }
    }

    private fun extractOfferType(lines: List<String>): String? {
        lines.firstOrNull {
            val normalized = normalizedText(it)
            normalized == "entrega carro" ||
                normalized == "entrega moto" ||
                normalized == "entrega" ||
                normalized == "negocia"
        }?.let { return it.trim() }

        val line =
            lines.firstOrNull {
                val normalized = normalizedText(it)
                normalized.contains("negocia") ||
                    normalized.contains("entrega") ||
                    normalized.contains("moto") ||
                    normalized.contains("carro")
            } ?: return null

        return line.split("•", "·").map { it.trim() }.firstOrNull {
            val normalized = normalizedText(it)
            normalized.contains("negocia") ||
                normalized.contains("entrega") ||
                normalized.contains("moto") ||
                normalized.contains("carro")
        }
    }

    private fun extractPaymentMethod(lines: List<String>): String? {
        val line =
            lines.firstOrNull {
                val normalized = normalizedText(it)
                normalized.contains("dinheiro") ||
                    normalized.contains("pix") ||
                    normalized.contains("cartao")
            } ?: return null

        return line.split("•", "·").map { it.trim() }.firstOrNull {
            val normalized = normalizedText(it)
            normalized.contains("dinheiro") ||
                normalized.contains("pix") ||
                normalized.contains("cartao")
        }
    }

    private fun findNodeContaining(
        node: AccessibilityNodeInfo,
        expectedText: String,
    ): AccessibilityNodeInfo? {
        val nodeText = normalizedText(node.text?.toString())
        val contentDescription = normalizedText(node.contentDescription?.toString())

        if (nodeText.contains(expectedText) || contentDescription.contains(expectedText)) {
            return node
        }

        for (index in 0 until node.childCount) {
            val child = node.getChild(index) ?: continue
            val found = findNodeContaining(child, expectedText)
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
        val nodeText = node.text?.toString().orEmpty()
        if (regex.containsMatchIn(nodeText)) {
            return node
        }

        for (index in 0 until node.childCount) {
            val child = node.getChild(index) ?: continue
            val found = findNodeByRegex(child, regex)
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
        val nodeText = node.text?.toString().orEmpty()

        if (regex.containsMatchIn(nodeText)) {
            result.add(node)
        }

        for (index in 0 until node.childCount) {
            val child = node.getChild(index) ?: continue
            result.addAll(findAllNodesByRegex(child, regex))
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

    private fun collectNonEmptyTexts(
        node: AccessibilityNodeInfo,
        result: MutableList<String> = mutableListOf(),
    ): List<String> {
        val text = node.text?.toString()?.trim()
        if (!text.isNullOrEmpty()) {
            result.add(text)
        }

        val contentDescription = node.contentDescription?.toString()?.trim()
        if (!contentDescription.isNullOrEmpty()) {
            result.add("cd:$contentDescription")
        }

        for (index in 0 until node.childCount) {
            val child = node.getChild(index) ?: continue
            collectNonEmptyTexts(child, result)
        }

        return result
    }
}
