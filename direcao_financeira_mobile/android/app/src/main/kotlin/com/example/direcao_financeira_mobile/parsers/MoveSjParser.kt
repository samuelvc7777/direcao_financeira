package com.example.direcao_financeira_mobile.parsers

import android.view.accessibility.AccessibilityNodeInfo
import java.util.regex.Pattern

class MoveSjParser {

    fun isOfferScreen(rootNode: AccessibilityNodeInfo): Boolean {
        return findNodeByText(rootNode, "Deslize para recusar") != null || 
               findNodeByText(rootNode, "Deslize para aceitar") != null
    }

    fun parseOffer(rootNode: AccessibilityNodeInfo): Map<String, Any> {
        val data = mutableMapOf<String, Any>()
        data["app"] = "moveSj"

        // 1. Capturar Valor (Ex: R$ 12,00)
        val priceNode = findNodeByRegex(rootNode, Regex("R\\$\\s*\\d+([.,]\\d+)?"))
        data["valor_bruto"] = priceNode?.text?.toString() ?: "R$ 0,00"

        // 2. Capturar Distâncias e Tempos (Usando a lógica das imagens)
        // Foto 1 mostra: 0,1 km (1 min) e 2,3 km (7 min)
        val kmTimeMatches = findAllNodesByRegex(rootNode, Regex("\\d+([.,]\\d+)?\\s*km\\s*\\(\\d+\\s*min\\)"))
        
        var totalKm = 0.0
        var totalMin = 0
        
        kmTimeMatches.forEach { node ->
            val text = node.text.toString()
            // Extrair KM
            val kmValue = Regex("(\\d+([.,]\\d+)?)").find(text)?.value?.replace(",", ".")?.toDoubleOrNull() ?: 0.0
            // Extrair Minutos
            val minValue = Regex("\\((\\d+)").find(text)?.groupValues?.get(1)?.toIntOrNull() ?: 0
            
            totalKm += kmValue
            totalMin += minValue
        }
        
        data["km_total"] = totalKm
        data["minutos_total"] = totalMin

        // 3. Capturar Nome e Avaliação (Foto 3)
        // O nome geralmente vem antes da avaliação "5,00★"
        val ratingNode = findNodeByRegex(rootNode, Regex("\\d+([.,]\\d+)?\\s*★"))
        data["avaliacao"] = ratingNode?.text?.toString() ?: "5,00★"
        
        // O nome costuma ser o nó de texto simples próximo à foto
        data["motorista"] = extractDriverName(rootNode) ?: "Motorista"

        return data
    }

    private fun extractDriverName(node: AccessibilityNodeInfo): String? {
        // Busca heurística: Texto curto (nome) que não contenha R$, km, min ou ★
        val text = node.text?.toString() ?: ""
        if (text.length in 3..20 && 
            !text.contains("R$") && 
            !text.contains("km") && 
            !text.contains("min") && 
            !text.contains("★") &&
            !text.contains("Deslize")) {
            return text
        }
        for (i in 0 until node.childCount) {
            val name = extractDriverName(node.getChild(i) ?: continue)
            if (name != null) return name
        }
        return null
    }

    private fun findNodeByText(node: AccessibilityNodeInfo, text: String): AccessibilityNodeInfo? {
        if (node.text?.toString()?.contains(text, ignoreCase = true) == true) return node
        for (i in 0 until node.childCount) {
            val found = findNodeByText(node.getChild(i) ?: continue, text)
            if (found != null) return found
        }
        return null
    }

    private fun findNodeByRegex(node: AccessibilityNodeInfo, regex: Regex): AccessibilityNodeInfo? {
        val nodeText = node.text?.toString() ?: ""
        if (regex.containsMatchIn(nodeText)) return node
        for (i in 0 until node.childCount) {
            val found = findNodeByRegex(node.getChild(i) ?: continue, regex)
            if (found != null) return found
        }
        return null
    }

    private fun findAllNodesByRegex(node: AccessibilityNodeInfo, regex: Regex): List<AccessibilityNodeInfo> {
        val result = mutableListOf<AccessibilityNodeInfo>()
        val nodeText = node.text?.toString() ?: ""
        if (regex.containsMatchIn(nodeText)) result.add(node)
        for (i in 0 until node.childCount) {
            result.addAll(findAllNodesByRegex(node.getChild(i) ?: continue, regex))
        }
        return result
    }
}
