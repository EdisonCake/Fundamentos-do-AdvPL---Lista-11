#INCLUDE 'TOTVS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'RPTDEF.CH'
#INCLUDE 'FWPRINTSETUP.CH'

#DEFINE LINHA_1     105
#DEFINE LINHA_FIM   770

#DEFINE VERMELHO    RGB(128,0,0)
#DEFINE PRETO       RGB(0, 0, 0)

/*/{Protheus.doc} User Function L11E01
    Função de usuário para a impressão de relatório de produtos com FwMsPrinter.
    @type  Function
    @author user
    @since 14/04/2023
    /*/
User Function L11E01()
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

    cQuery := "SELECT B1_COD, B1_DESC, B1_UM, B1_PRV1, B1_LOCPAD, B1_MSBLQL FROM " + RetSqlName("SB1") + " WHERE D_E_L_E_T_ = ' '"
    TCQUERY cQuery ALIAS (cAlias) NEW

    (cAlias)->(DbGoTop())

    if (cAlias)->(Eof())
        cAlias := ""
    endif

    RestArea(aArea)
Return cAlias

Static Function MontaRel(cAlias)
    local cCaminho := "C:\Users\ediso\Desktop\"
    local cArquivo := "CadProdutos.pdf"

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

    Top()
    Info(cAlias)

    oPrint:EndPage()
    oPrint:Preview()
Return

Static Function Top()
    oPrint:Box(15, 15, 85, 580, '-8')
    oPrint:Line(50, 15, 50, 580,,'-6')

    oPrint:Say(35, 020, "Empresa/Filial: " + alltrim(SM0->M0_NOME) + "/" + alltrim(SM0->M0_FILIAL), oFont14)
    oPrint:Say(70, 220, "Cadastro de Produtos", oFont16)

    oPrint:Say(nLinha, 020, "CÓDIGO"    , oFont12)
    oPrint:Say(nLinha, 080, "PRODUTO"   , oFont12)
    oPrint:Say(nLinha, 400, "U.M."      , oFont12)
    oPrint:Say(nLinha, 450, "PREÇO"     , oFont12)
    oPrint:Say(nLinha, 540, "ARMAZÉM"   , oFont12)

    nLinha += 5
    oPrint:Line(nLinha, 15, nLinha, 580,, '-6')

    nLinha += 20
Return

Static Function Info(cAlias)
    local cString := ""
    private nCor  := 0

    DbSelectArea(cAlias)
    (cAlias)->(DbGoTop())

    While (cAlias)->(!EoF())
        Final(LINHA_FIM)

        if alltrim((cAlias)->(B1_MSBLQL)) == "1"
            nCor := VERMELHO
        else
            nCor := PRETO
        endif
        
        cString := alltrim((cAlias)->(B1_COD))
        Quebra(cString, 10, 20)

        cString := alltrim((cAlias)->(B1_DESC))
        Quebra(cString, 50, 80)

        oPrint:Say(nLinha, 400, alltrim((cAlias)->(B1_UM)), oFont10,, nCor)

        if (cAlias)->(B1_PRV1) == 0
            cString := "0.00"
        else
            cString := cvaltochar((cAlias)->(B1_PRV1))
        endif

        oPrint:Say(nLinha, 450, "R$ " + cString, oFont10,, nCor)

        oPrint:Say(nLinha, 540, alltrim((cAlias)->(B1_LOCPAD)), oFont10,, nCor)

        nLinha += 30
        IncProc()
        (cAlias)->(DbSkip())
    End Do

Return

Static Function Final(nLinhaFinal)
    if nLinha > nLinhaFinal
        oPrint:EndPage()
        oPrint:StartPage()

        nLinha := LINHA_1
        Top()
    endif
Return

Static Function Quebra(cString, nChar, nColuna)
    local cText     := ""
    local lQuebra   := .F.
    local nLinhas   := MlCount(cString, nChar,, .F.)
    local nCount    := 0

    if nLinhas > 1
        lQuebra := .T.
        For nCount := 1 to nLinhas
            cText := MemoLine(cString, nChar, nCount)
            oPrint:Say(nLinha, nColuna, cText, oFont10,, nCor)
            nLinha += 10
        Next
    else
        oPrint:Say(nLinha, nColuna, cString, oFont10,, nCor)
    endif

    if lQuebra
        nLinha -= (nLinhas * 10)
    endif

Return
