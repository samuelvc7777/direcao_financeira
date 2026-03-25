package com.example.direcao_financeira_mobile.parsers

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class MoveSjParserTest {

    private val parser = MoveSjParser()

    @Test
    fun `mantem origem e destino na ordem correta quando endereco esta quebrado em linhas`() {
        val offerData =
            parser.parseOfferFromLines(
                lines =
                    listOf(
                        "R$ 18,50",
                        "5,4 km (R$ 3,42 / km)",
                        "17 min (R$ 1,08 / min)",
                        "1,3 km (3 min)",
                        "Rua Antonio Floriano da Silva, 5 - Sao Joao del Rei - MG",
                        "1,1 km (3 min)",
                        "Igreja de Sao Francisco de Assis -",
                        "Praca Frei Orlando - Centro, Sao Joao del Rei - MG",
                        "Deslize para aceitar",
                    ),
                priceText = "R$ 18,50",
            )

        assertEquals(
            "Rua Antonio Floriano da Silva, 5 - Sao Joao del Rei - MG",
            offerData["origin_address"],
        )
        assertEquals(
            "Igreja de Sao Francisco de Assis - Praca Frei Orlando - Centro, Sao Joao del Rei - MG",
            offerData["destination_address"],
        )
    }

    @Test
    fun `nao perde sufixo repetido da cidade no segundo endereco`() {
        val offerData =
            parser.parseOfferFromLines(
                lines =
                    listOf(
                        "1,3 km (3 min)",
                        "Rua A, 10",
                        "Centro, Sao Joao del Rei - MG",
                        "1,1 km (3 min)",
                        "Praca B, 25",
                        "Centro, Sao Joao del Rei - MG",
                    ),
            )

        assertEquals(
            "Rua A, 10 Centro, Sao Joao del Rei - MG",
            offerData["origin_address"],
        )
        assertEquals(
            "Praca B, 25 Centro, Sao Joao del Rei - MG",
            offerData["destination_address"],
        )
    }

    @Test
    fun `usa os trechos da rota como fallback para km e minutos`() {
        val offerData =
            parser.parseOfferFromLines(
                lines =
                    listOf(
                        "1,3 km (3 min)",
                        "Rua Antonio Floriano da Silva, 5 - Sao Joao del Rei - MG",
                        "1,1 km (3 min)",
                        "Praca Frei Orlando - Centro, Sao Joao del Rei - MG",
                    ),
                priceText = "R$ 18,50",
            )

        assertEquals(2.4, offerData["km_total"])
        assertEquals(6, offerData["minutos_total"])
    }

    @Test
    fun `reconhece tela da movesj com botoes de aceitar e recusar`() {
        val isOfferScreen =
            parser.isOfferScreenFromLines(
                listOf(
                    "Move",
                    "RECUSAR",
                    "R$ 12,66",
                    "Samuel",
                    "5,00\\u2605",
                    "1,5 km (R$ 8,61 / km)",
                    "4 min (R$ 2,98 / min)",
                    "0 m (1 min)",
                    "R. Joaquim Portugal, 15 - Matozinhos, Sao Joao del Rei - MG, 36305-174, Brasil",
                    "1,5 km (4 min)",
                    "Av. Leite de Castro, 617 - Fabricas, Sao Joao del Rei - MG, 36301-182, Brasil",
                    "ACEITAR (12)",
                ),
            )

        assertTrue(isOfferScreen)
    }

    @Test
    fun `nao reconhece tela generica sem marcadores de oferta`() {
        val isOfferScreen =
            parser.isOfferScreenFromLines(
                listOf(
                    "Move",
                    "Ola, Samuel",
                    "Historico",
                    "Ganhos da semana",
                    "R$ 120,00",
                ),
            )

        assertFalse(isOfferScreen)
    }
}
