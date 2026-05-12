package com.example.direcao_financeira_mobile.parsers

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Test

class NinetyNineOcrParserTest {

    private val parser = NinetyNineOcrParser()

    @Test
    fun `extrai origem e destino a partir dos blocos de rota da 99`() {
        val lines =
            listOf(
                "Máquina cartão",
                "R$13,90",
                "Passageiro novo",
                "Perfil Premium",
                "11min (3,2km)",
                "Rua do Jacarandá, 120, Matozinhos",
                "9min (2,4km)",
                "Upa São João Del Rei, Rua Mal. Ciro Espírito Santo Cardoso, 173 - CAIEI...",
                "Google",
            )

        val rawText = lines.joinToString("\n")
        val offerData = parser.parseOffer(rawText, lines)

        assertNotNull(offerData)
        assertEquals("Rua do Jacarandá, 120, Matozinhos", offerData?.get("origin_address"))
        assertEquals(
            "Upa São João Del Rei, Rua Mal. Ciro Espírito Santo Cardoso, 173 - CAIEI...",
            offerData?.get("destination_address"),
        )
    }

    @Test
    fun `ignora textos do mapa e do card ao procurar endereco da 99`() {
        val lines =
            listOf(
                "Santa Cruz de Minas",
                "Matozinhos",
                "Máquina cartão",
                "R$13,90",
                "Perfil Premium",
                "11min (3,2km)",
                "Rua do Jacarandá, 120, Matozinhos",
                "9min (2,4km)",
                "Upa São João Del Rei, Rua Mal. Ciro Espírito Santo Cardoso, 173 - CAIEI...",
                "Google",
            )

        val rawText = lines.joinToString("\n")
        val offerData = parser.parseOffer(rawText, lines)

        assertNotNull(offerData)
        assertEquals("Rua do Jacarandá, 120, Matozinhos", offerData?.get("origin_address"))
        assertEquals(
            "Upa São João Del Rei, Rua Mal. Ciro Espírito Santo Cardoso, 173 - CAIEI...",
            offerData?.get("destination_address"),
        )
    }
}
