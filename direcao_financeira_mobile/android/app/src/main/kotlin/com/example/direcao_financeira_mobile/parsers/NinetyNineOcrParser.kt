package com.example.direcao_financeira_mobile.parsers

import java.text.Normalizer

class NinetyNineOcrParser {

    private val priceRegex = Regex("R\\$\\s*\\d+(?:[.,]\\d+)?")
    private val statsRegex =
        Regex("(\\d+)\\s*min\\s*\\((\\d+(?:[.,]\\d+)?)\\s*km\\)", RegexOption.IGNORE_CASE)
    private val corridasLineRegex =
        Regex("(\\d+(?:[.,]\\d+)?)\\s*(?:[\\u2022·•]|\\.)?\\s*(\\d+)\\s*corridas", RegexOption.IGNORE_CASE)
    private val ratingProfileLineRegex =
        Regex("(\\d+(?:[.,]\\d+)?)\\s*(?:[\\u2022·•]|\\.)\\s*perfil\\b", RegexOption.IGNORE_CASE)
    private val fallbackRatingRegex = Regex("\\b\\d(?:[.,]\\d{1,2})\\b")
    private val profileRegex =
        Regex("Perfil\\s+[A-Za-zÀ-ÿ]+(?:\\s+[A-Za-zÀ-ÿ]+)?", RegexOption.IGNORE_CASE)

    fun buildDebugSnapshot(
        rawText: String,
        lines: List<String>,
    ): Map<String, Any> {
        return mapOf(
            "priceText" to (priceRegex.find(rawText)?.value.orEmpty()),
            "statsCount" to statsRegex.findAll(rawText).count(),
            "hasPrecoX" to normalize(rawText).contains("preco x"),
            "hasNaoAfetaTA" to normalize(rawText).contains("nao afeta a ta"),
            "hasPerfil" to (extractProfile(lines) != null),
            "offerType" to (extractOfferType(lines) ?: ""),
            "paymentMethod" to (extractPaymentMethod(lines) ?: ""),
            "rating" to (extractRating(rawText, lines) ?: ""),
            "ridesCount" to (extractRidesCount(rawText, lines) ?: 0),
            "profile" to (extractProfile(lines) ?: ""),
            "sampleLines" to lines.take(12),
        )
    }

    fun parseOffer(
        rawText: String,
        lines: List<String>,
    ): Map<String, Any>? {
        if (rawText.isBlank()) {
            return null
        }

        val normalizedText = normalize(rawText)
        val price = priceRegex.find(rawText)?.value ?: return null
        val stats = statsRegex.findAll(rawText).toList()
        val hasMarkers =
            normalizedText.contains("preco x") ||
                normalizedText.contains("perfil") ||
                normalizedText.contains("nao afeta a ta") ||
                normalizedText.contains("aceitar por")

        if (stats.size < 2 && !hasMarkers) {
            return null
        }

        var totalMinutes = 0
        var totalKm = 0.0

        stats.forEach { match ->
            totalMinutes += match.groupValues[1].toIntOrNull() ?: 0
            totalKm += match.groupValues[2].replace(",", ".").toDoubleOrNull() ?: 0.0
        }

        return mutableMapOf<String, Any>().apply {
            put("app", "99")
            put("valor_bruto", price)
            put("km_total", totalKm)
            put("minutos_total", totalMinutes)
            put("avaliacao", extractRating(rawText, lines) ?: "5,00")
            put("corridas_total", extractRidesCount(rawText, lines) ?: 0)
            put("perfil_passageiro", extractProfile(lines) ?: "")
            put("tipo_corrida", extractOfferType(lines) ?: "")
            put("forma_pagamento", extractPaymentMethod(lines) ?: "")
            put("motorista", "99")
        }
    }

    private fun extractRating(
        rawText: String,
        lines: List<String>,
    ): String? {
        val corridasLine =
            lines.firstOrNull { normalize(it).contains("corridas") }
                ?: rawText.lineSequence().firstOrNull { normalize(it).contains("corridas") }

        if (!corridasLine.isNullOrBlank()) {
            corridasLineRegex.find(corridasLine)?.groupValues?.get(1)?.let { return it }
            fallbackRatingRegex.find(corridasLine)?.value?.let { return it }
        }

        val perfilLine =
            lines.firstOrNull { normalize(it).contains("perfil") }
                ?: rawText.lineSequence().firstOrNull { normalize(it).contains("perfil") }

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
            lines.firstOrNull { normalize(it).contains("corridas") }
                ?: rawText.lineSequence().firstOrNull { normalize(it).contains("corridas") }

        return corridasLine?.let { corridasLineRegex.find(it)?.groupValues?.get(2)?.toIntOrNull() }
    }

    private fun extractProfile(lines: List<String>): String? {
        return lines.firstOrNull { profileRegex.containsMatchIn(it) }
            ?.let { profileRegex.find(it)?.value?.trim() }
    }

    private fun extractOfferType(lines: List<String>): String? {
        lines.firstOrNull {
            val normalized = normalize(it)
            normalized == "entrega carro" ||
                normalized == "entrega moto" ||
                normalized == "entrega" ||
                normalized == "negocia"
        }?.let { return it.trim() }

        val line =
            lines.firstOrNull {
                val normalized = normalize(it)
                normalized.contains("negocia") ||
                    normalized.contains("entrega") ||
                    normalized.contains("moto") ||
                    normalized.contains("carro")
            } ?: return null

        return line.split("•", "·").map { it.trim() }.firstOrNull {
            val normalized = normalize(it)
            normalized.contains("negocia") ||
                normalized.contains("entrega") ||
                normalized.contains("moto") ||
                normalized.contains("carro")
        }
    }

    private fun extractPaymentMethod(lines: List<String>): String? {
        val line =
            lines.firstOrNull {
                val normalized = normalize(it)
                normalized.contains("dinheiro") ||
                    normalized.contains("pix") ||
                    normalized.contains("cartao")
            } ?: return null

        return line.split("•", "·").map { it.trim() }.firstOrNull {
            val normalized = normalize(it)
            normalized.contains("dinheiro") ||
                normalized.contains("pix") ||
                normalized.contains("cartao")
        }
    }

    private fun normalize(value: String): String {
        val normalized =
            Normalizer.normalize(value, Normalizer.Form.NFD)
                .replace("\\p{InCombiningDiacriticalMarks}+".toRegex(), "")

        return normalized.lowercase()
    }
}
