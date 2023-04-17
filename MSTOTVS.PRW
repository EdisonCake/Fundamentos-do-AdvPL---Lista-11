#INCLUDE 'TOTVS.CH'
#INCLUDE 'REPORT.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'RPTDEF.CH'
#INCLUDE 'FWPRINTSETUP.CH'

#DEFINE VERMELHO    RGB(139,0,0)
#DEFINE AZUL        RGB(25,25,112)

#DEFINE LINHA_1     105
#DEFINE LINHA_FIM   770

/*/{Protheus.doc} User Function MsTOTVS
    Função de usuário para realizar a impressão detalhada de todos os pedidos de compra na rotina (Exercício 05), acrescida de totalizadores em cada pedidos (Exercício 04).
    @type  Function
    @author Edison Cake
    @since 14/04/2023
    /*/
User Function MsTOTVS()
    local cAlias := GeraCons()

    if !Empty(cAlias)

        Processa({|| MontaRel(cAlias)}, "Aguarde...", "Gerando Informações.", .F.)
    else

        FwAlertError("Nenhum registro encontrado.", "Atenção!")
    endif
Return 

Static Function GeraCons()
    local aArea     := GetArea()
    local cAlias    := GetNextAlias()
    local cQuery := ""

    cQuery := "SELECT SC7.C7_NUM, SC7.C7_EMISSAO, SC7.C7_FORNECE, SA2.A2_CGC, SA2.A2_NOME, SC7.C7_LOJA, SC7.C7_COND, SC7.C7_PRODUTO, SC7.C7_DESCRI, SC7.C7_QUANT, SC7.C7_PRECO, SC7.C7_TOTAL, SE4.E4_DESCRI FROM " + RetSqlName("SC7") + " SC7 INNER JOIN " + RetSqlName("SA2") + " SA2 ON SC7.C7_FORNECE = SA2.A2_COD INNER JOIN " + RetSqlName("SE4") + " SE4 ON SC7.C7_COND = SE4.E4_CODIGO WHERE SC7.D_E_L_E_T_ = ' '"

    TCQUERY cQuery ALIAS (cAlias) NEW
    (cAlias)->(DbGoTop())

    if (cAlias)->(Eof())
        cAlias := ""
    endif

    RestArea(aArea)
Return cAlias

Static Function MontaRel(cAlias)
    local cCaminho  := "C:\Users\ediso\Desktop\"
    local cArquivo  := "Detalhes_Pedidos.pdf"
    local cPedido   := ""
    local nTotPed   := 0
    local nPage     := 0

    private nLinha := LINHA_1
    private oPrint

    private oFont10 := TFont():New("Fira Code",,10,,.F.,,,,,.F.,.F.)
    private oFont12 := TFont():New("Fira Code",,12,,.T.,,,,,.F.,.F.)
    private oFont14 := TFont():New("Fira Code",,14,,.T.,,,,,.F.,.F.)
    private oFont16 := TFont():New("Fira Code",,16,,.T.,,,,,.T.,.F.)

    oPrint := FwMsPrinter():New(cArquivo, IMP_PDF, .F., "", .T.,, @oPrint,,,,, .T.)
    oPrint:cPathPDF := cCaminho
    oPrint:SetPortrait()
    oPrint:SetPaperSize(9)
    oPrint:StartPage()

    DbSelectArea(cAlias)
    (cAlias)->(DbGoTop())

    While (cAlias)->(!Eof())

        if cPedido <> alltrim((cAlias)->(C7_NUM))
            if !Empty(cPedido)
                oPrint:Line(nLinha, 450, nLinha, 580)
                nLinha += 10

                oPrint:Say(nLinha, 450, "TOTAL", oFont12,, AZUL)
                oPrint:Say(nLinha, 530, "R$ " + cvaltochar(nTotPed), oFont12,, VERMELHO)

                nTotped := 0

                oPrint:EndPage()
                oPrint:StartPage()

                nPage++
                oPrint:Say(820, 530, cvaltochar(nPage), oFont10,, AZUL)

                nLinha := LINHA_1
                Top(cAlias)

            else
                nLinha := LINHA_1
                Top(cAlias)

                nPage++
                oPrint:Say(820, 530, cvaltochar(nPage), oFont10,, AZUL)

            endif
        endif
    
        cPedido := alltrim((cAlias)->(C7_NUM))
        Info(cAlias)

        nTotPed += (cAlias)->(C7_TOTAL)
        (cAlias)->(DbSkip())
    End do

    oPrint:Line(nLinha, 450, nLinha, 580)
    nLinha += 10

    oPrint:Say(nLinha, 450, "TOTAL", oFont12,, AZUL)
    oPrint:Say(nLinha, 530, "R$ " + cvaltochar(nTotPed), oFont12,, VERMELHO)

    oPrint:EndPage()
    oPrint:Preview()
Return

Static Function Top(cAlias)
    local cString := ""

    oPrint:Box(15, 15, 85, 580, '-8')
    oPrint:Line(50, 15, 50, 580,,'-6')

    oPrint:Say(35, 020, "Empresa/Filial: " + alltrim(SM0->M0_NOME) + "/" + alltrim(SM0->M0_FILIAL), oFont14)
    oPrint:Say(70, 020, "Informações do Pedido " + alltrim((cAlias)->(C7_NUM)), oFont14)

    if !Empty((cAlias)->(A2_CGC))
        oPrint:Say(70, 320, "CPF/CNPJ:  " + alltrim((cAlias)->(A2_CGC)), oFont14)
    else
        oPrint:Say(70, 320, "Sem informações de CPF/CNPJ.", oFont14,, VERMELHO)
    endif

    oPrint:Say(nLinha, 020, "FORNECEDOR", oFont12,, AZUL)
    oPrint:Say(nLinha, 200, "LOJA.FORN.", oFont12,, AZUL)
    oPrint:Say(nLinha, 320, "PAGAMENTO" , oFont12,, AZUL)
    oPrint:Say(nLinha, 485, "EMISSÃO"   , oFont12,, AZUL)

    nLinha += 5
    oPrint:Line(nLinha, 15, nLinha, 580,, '-6')
    nLinha += 10

    oPrint:Say(nLinha, 020, alltrim((cAlias)->(C7_FORNECE)), oFont12,, VERMELHO)
    cString := alltrim((cAlias)->(A2_NOME))
    xQuebraCab(cString, 20, 80)

    oPrint:Say(nLinha, 200, alltrim((cAlias)->(C7_LOJA)), oFont12,, VERMELHO)
    oPrint:Say(nLinha, 320, alltrim((cAlias)->(C7_COND)) + " - " + alltrim((cAlias)->(E4_DESCRI)), oFont12,, VERMELHO)
    cString := DtoC(StoD((cAlias)->(C7_EMISSAO)))
    oPrint:Say(nLinha, 485, cString, oFont12,, VERMELHO)
    nLinha += 30


    oPrint:Say(nLinha, 020, "CÓDIGO",   oFont12,, AZUL)
    oPrint:Say(nLinha, 200, "PRODUTO",  oFont12,, AZUL)
    oPrint:Say(nLinha, 400, "QTD.",     oFont12,, AZUL)
    oPrint:Say(nLinha, 450, "UNITÁRIO", oFont12,, AZUL)
    oPrint:Say(nLinha, 540, "TOTAL",    oFont12,, AZUL)

    nLinha += 5
    oPrint:Line(nLinha, 15, nLinha, 580,, '-6')
    nLinha += 10
Return

Static Function Info(cAlias)
    local cString := ""

    Final(LINHA_FIM, cAlias)

    cString := alltrim((cAlias)->(C7_PRODUTO))
    QuebraCorpo(cString, 20, 20)

    cString := alltrim((cAlias)->(C7_DESCRI))
    QuebraCorpo(cString, 50, 200)

    oPrint:Say(nLinha, 400, cvaltochar((cAlias)->(C7_QUANT)), oFont10,, VERMELHO)
    oPrint:Say(nLinha, 450, "R$ " + cvaltochar((cAlias)->(C7_PRECO)), oFont10,, VERMELHO)
    oPrint:Say(nLinha, 540, "R$ " + cvaltochar((cAlias)->(C7_TOTAL)), oFont10,, VERMELHO)
        
    nLinha += 30
    IncProc()
Return

Static Function xQuebraCab(cString, nChar, nColuna)
    local cText     := ""
    local lQuebra   := .F.
    local nLinhas   := MlCount(cString, nChar,, .F.)
    local nCount    := 0

    if nLinhas > 1
        lQuebra := .T.
        For nCount := 1 to nLinhas
            cText := MemoLine(cString, nChar, nCount)
            oPrint:Say(nLinha, nColuna, cText, oFont12,, VERMELHO)
            nLinha += 10
        Next
    else
        oPrint:Say(nLinha, nColuna, cString, oFont12,, VERMELHO)
    endif

    if lQuebra
        nLinha -= (nLinhas * 10)
    endif

Return

Static Function QuebraCorpo(cString, nChar, nColuna)
    local cText     := ""
    local lQuebra   := .F.
    local nLinhas   := MlCount(cString, nChar,, .F.)
    local nCount    := 0

    if nLinhas > 1
        lQuebra := .T.
        For nCount := 1 to nLinhas
            cText := MemoLine(cString, nChar, nCount)
            oPrint:Say(nLinha, nColuna, cText, oFont10,, VERMELHO)
            nLinha += 10
        Next
    else
        oPrint:Say(nLinha, nColuna, cString, oFont10,, VERMELHO)
    endif

    if lQuebra
        nLinha -= (nLinhas * 10)
    endif

Return

Static Function Final(nLinhaFinal, cAlias)
    if nLinha > nLinhaFinal
        oPrint:EndPage()
        oPrint:StartPage()

        nLinha := LINHA_1
        Top(cAlias)
    endif
Return
