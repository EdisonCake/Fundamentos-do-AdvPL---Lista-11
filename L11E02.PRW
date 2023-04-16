#INCLUDE 'TOTVS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'RPTDEF.CH'
#INCLUDE 'FWPRINTSETUP.CH'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE LINHA_1     105
#DEFINE LINHA_FIM   770

/*/{Protheus.doc} User Function L11E02
    Browse de cadastro de Fornecedores com botão adicional de relatório.
    @type  Function
    @author user
    @since 14/04/2023
    /*/
User Function L11E02()
    local cAlias    := 'SA2'
    local cTitle    := "Cadastro de Fornecedores"
    local oBrowse   := FWMBrowse():New()

    oBrowse:SetAlias(cAlias)
    oBrowse:SetDescription(cTitle)
    oBrowse:DisableReport()
    oBrowse:DisableDetails()

    oBrowse:AddButton("Imprimir Informações", {|| PrintForn()})

    oBrowse:Activate()
Return 

Static Function MenuDef()
    local aRotina := {}

    ADD OPTION aRotina TITLE "Visualizar"   ACTION 'VIEWDEF.L11E02' OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE "Inserir"      ACTION 'VIEWDEF.L11E02' OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"      ACTION 'VIEWDEF.L11E02' OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"      ACTION 'VIEWDEF.L11E02' OPERATION 5 ACCESS 0

Return aRotina

Static Function ModelDef()
    local oModel    := MpFormModel():New("L11E02M")
    local oStruSA2  := FWFormStruct(1, "SA2")

    oModel:AddFields("SA2MASTER",, oStruSA2)
    oModel:SetDescription("Cadastro de Fornecedores")
    oModel:SetPrimaryKey({"A2_COD"})

Return oModel

Static Function ViewDef()
    local oModel    := FwLoadModel("L11E02")
    local oStruSA2  := FWFormStruct(2, "SA2")
    local oView     := FwFormView():New()

    oView:SetModel(oModel)
    oView:AddField("VIEW_SA2", oStruSA2, "SA2MASTER")
    oView:CreateHorizontalBox("FORNECEDORES", 100)
    oView:SetOwnerView("VIEW_SA2", "FORNECEDORES")
    oView:EnableTitleView("VIEW_SA2", "Cadastro de Fornecedores")

Return oView

Static Function PrintForn()
    local cAlias := GeraCons()

    if !Empty(cAlias)

        Processa({|| MontaRel(cAlias)}, "Aguarde...", "Buscando dados!", .F.)
    else

        FwAlertError("Nenhum registro encontrado.", "Atenção!")
    endif
Return 

Static Function GeraCons()
    local aArea     := GetArea()
    local cAlias    := GetNextAlias()
    local cQuery := ""

    cQuery := "SELECT A2_COD, A2_NREDUZ, A2_NOME, A2_END, A2_BAIRRO, A2_EST, A2_MUN, A2_CEP, A2_CGC FROM " + RetSqlName("SA2") + " WHERE A2_COD = '" + alltrim(SA2->A2_COD) + "' AND D_E_L_E_T_ = ' '"
    TCQUERY cQuery ALIAS (cAlias) NEW

    (cAlias)->(DbGoTop())

    if (cAlias)->(Eof())
        cAlias := ""
    endif

    RestArea(aArea)
Return cAlias

Static Function MontaRel(cAlias)
    local cCaminho := "C:\Users\ediso\Desktop\"
    local cArquivo := "Info_Fornecedor.pdf"

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

    PrePrint(cAlias)
    Info(cAlias)

    oPrint:EndPage()
    oPrint:Preview()
Return

Static Function PrePrint(cAlias)
    oPrint:Box(15, 15, 85, 580, '-8')
    oPrint:Line(50, 15, 50, 580,,'-6')

    oPrint:Say(35, 020, "Nome Fantasia: " + alltrim((cAlias)->(A2_NREDUZ)), oFont14)
    oPrint:Say(70, 220, "INFORMAÇÕES DO FORNECEDOR", oFont16)

    oPrint:Say(nLinha, 020, "CÓDIGO"        , oFont12)
    oPrint:Say(nLinha, 080, "RAZÃO SOCIAL"  , oFont12)
    oPrint:Say(nLinha, 200, "ENDEREÇO"      , oFont12)
    oPrint:Say(nLinha, 320, "BAIRRO"        , oFont12)
    oPrint:Say(nLinha, 400, "CIDADE"        , oFont12)
    oPrint:Say(nLinha, 485, "ESTADO"        , oFont12)

    nLinha += 5
    oPrint:Line(nLinha, 15, nLinha, 580,, '-6')

    nLinha += 10
Return

Static Function Info(cAlias)
    local cString := ""
    private nCor  := 0

    DbSelectArea(cAlias)
    (cAlias)->(DbGoTop())

    oPrint:Say(nLinha, 20, alltrim((cAlias)->(A2_COD)), oFont10)

    cString := alltrim((cAlias)->(A2_NOME))
    Quebra(cString, 24, 80)
    
    cString := alltrim((cAlias)->(A2_END))
    Quebra(cString, 20, 200)

    cString := alltrim((cAlias)->(A2_BAIRRO))
    Quebra(cString, 15, 320)

    cString := alltrim((cAlias)->(A2_MUN))
    Quebra(cString, 20, 400)

    oPrint:Say(nLinha, 485, alltrim((cAlias)->(A2_EST)), oFont10)
    
    nLinha += 30

    oPrint:Say(nLinha, 20, "Outras informações: ", oFont12)
    nLinha += 5

    oPrint:Line(nLinha, 15, nLinha, 580,, '-6')
    nLinha += 5

    oPrint:Say(nLinha, 20, "CPF/CNPJ: " + alltrim(A2_CGC), oFont10)
    nLinha += 10

    oPrint:Say(nLinha, 20, "CEP: " + alltrim(A2_CEP), oFont10)
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
            oPrint:Say(nLinha, nColuna, cText, oFont10)
            nLinha += 10
        Next
    else
        oPrint:Say(nLinha, nColuna, cString, oFont10)
    endif

    if lQuebra
        nLinha -= (nLinhas * 10)
    endif

Return
