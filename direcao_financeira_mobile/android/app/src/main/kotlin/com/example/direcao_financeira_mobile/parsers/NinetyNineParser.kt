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
        Regex("Perfil\\s+[A-Za-zÀ-ÿ]+(?:\\s+[A-Za-zÀ-ÿ]+)?", RegexOption.IGNORE_CASE)

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

    fun buildDebugSnapshot(rootNode: AccessibilityNodeInfo): Map<String, Any> {
        val priceNode = findNodeByRegex(rootNode, priceRegex)
        val statsMatches = findAllNodesByRegex(rootNode, statsRegex)
        val lines = collectVisibleTexts(rootNode)
        val rawText = lines.joinToString("\n")

        return mapOf(
            "hasMainPrice" to (priceNode != null),
            "priceText" to (priceNode?.text?.toString() ?: ""),
            "statsCount" to statsMatches.size,
            "statsTexts" to statsMatches.map { it.text?.toString().orEmpty() },
            "offerType" to (extractOfferType(lines) ?: ""),
            "paymentMethod" to (extractPaymentMethod(lines) ?: ""),
            "rating" to (extractRating(rawText, lines) ?: ""),
            "ridesCount" to (extractRidesCount(rawText, lines) ?: 0),
            "profile" to (extractProfile(lines) ?: ""),
            "sampleTexts" to lines.take(25),
        )
    }

    fun parseOffer(rootNode: AccessibilityNodeInfo): Map<String, Any> {
        val lines = collectVisibleTexts(rootNode)
        val rawText = lines.joinToString("\n")

        val data = mutableMapOf<String, Any>()
        data["app"] = "99"

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
        data["perfil_passageiro"] = extractProfile(lines) ?: ""
        data["tipo_corrida"] = extractOfferType(lines) ?: ""
        data["forma_pagamento"] = extractPaymentMethod(lines) ?: ""
        data["motorista"] = "99"

        return data
    }

    private fun collectVisibleTexts(rootNode: AccessibilityNodeInfo): List<String> {
        return collectNonEmptyTexts(rootNode)
            .map { it.removePrefix("cd:").trim() }
            .filter { it.isNotEmpty() }
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

    private fun extractProfile(lines: List<String>): String? {
        return lines.firstOrNull { profileRegex.containsMatchIn(it) }
            ?.let { profileRegex.find(it)?.value?.trim() }
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
