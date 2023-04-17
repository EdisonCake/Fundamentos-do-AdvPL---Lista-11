#INCLUDE 'TOTVS.CH'
#INCLUDE 'REPORT.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'RPTDEF.CH'
#INCLUDE 'FWPRINTSETUP.CH'

#DEFINE VERMELHO    RGB(139,0,0)
#DEFINE AZUL        RGB(25,25,112)

/*/{Protheus.doc} User Function MSCHALLENGE
    Função de usuário para realizar a impressão detalhada do pedido de venda selecionado pelo usuário (Exercício 03), acrescida de totalizador (Exercício 04), diferencial com algumas informações e recursos a mais (Challenge).
    @type  Function
    @author Edison Cake
    @since 17/04/2023
    /*/
User Function MSCHALLENGE()
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

    cQuery := "SELECT SC5.C5_NUM, SC5.C5_CONDPAG, SE4.E4_DESCRI, SC5.C5_TRANSP, SC5.C5_ESPECI1, SC5.C5_VOLUME1, SC5.C5_DESC1, SC5.C5_FRETE, SC5.C5_DESPESA, SC5.C5_TPFRETE, SA1.A1_COD, SA1.A1_NOME, SA1.A1_EMAIL, SA1.A1_END, SA1.A1_MUN, SA1.A1_EST, SA1.A1_TEL, SA1.A1_CGC, SA1.A1_BAIRRO, SA1.A1_CEP, SA1.A1_INSCR, SC6.C6_ITEM, SC6.C6_PRODUTO, SC6.C6_DESCRI, SC6.C6_UM, SC6.C6_QTDVEN, SC6.C6_PRCVEN, SC6.C6_VALOR, SC6.C6_ENTREG FROM " + RetSqlName("SC5") + " SC5 INNER JOIN " + RetSqlName("SA1") + " SA1 ON SC5.C5_CLIENTE = SA1.A1_COD INNER JOIN " + RetSqlName("SC6") + " SC6 ON SC5.C5_NUM = SC6.C6_NUM INNER JOIN "+ RetSqlName("SE4") + " SE4 ON SC5.C5_CONDPAG = SE4.E4_CODIGO WHERE C5_NUM = '" + alltrim(SC5->C5_NUM) + "'"

    TCQUERY cQuery ALIAS (cAlias) NEW
    (cAlias)->(DbGoTop())

    if (cAlias)->(Eof())
        cAlias := ""
    endif

    RestArea(aArea)
Return cAlias

Static Function MontaRel(cAlias)
    local cCaminho := "C:\Users\ediso\Desktop\"
    local cArquivo := "Challenge_" + alltrim((cAlias)+(C5_NUM)) + ".pdf"

    private oPrint
    private nLinha := 0

    private oFira8Reg := TFont():New("Fira Code",,8,,.F.,,,,,.F.,.F.) // Fira Code, 8px, regular
    private oFira10Bold := TFont():New("Fira Code",,10,,.T.,,,,,.F.,.F.) // Fira Code, 10px, negrito
    private oFira10Reg  := TFont():New("Fira Code",,10,,.F.,,,,,.F.,.F.) // Fira Code, 10px, regular
    private oFira12Bold := TFont():New("Fira Code",,12,,.T.,,,,,.F.,.F.) // Fira Code, 12px, negrito
    private oFira12Reg  := TFont():New("Fira Code",,12,,.F.,,,,,.F.,.F.) // Fira Code, 12px, regular
    private oFira15     := TFont():New("Fira Code",,15,,.T.,,,,,.F.,.F.) // Fira Code, 15px, negrito

    oPrint := FwMsPrinter():New(cArquivo, IMP_PDF, .F., "", .T.,, @oPrint,,,,, .T.)
    oPrint:cPathPDF := cCaminho
    oPrint:SetPortrait()
    oPrint:SetPaperSize(9)
    oPrint:StartPage()

    Inicio()
    Top(cAlias)
    Cliente(cAlias)
    Info(cAlias)
    Bottom(cAlias)

    oPrint:EndPage()
    oPrint:Preview()
Return

Static Function Inicio()
    local cImage := ('\system\LGMID.png')

    nLinha := 30

    // Impressão da logomarca (tamanho padrão 100px x 100px).
    oPrint:SayBitmap(15, 15, cImage)

    // Iniciando a impressão das informações do pré-cabeçalho.
    oPrint:Say(nLinha, 430, "Edison Cake (TOTVS IP)", oFira15,, AZUL)

    nLinha += 10
    oPrint:Say(nLinha, 320, "Rua Dr. Antônio Carlos Couto de Barros, 937, Souzas - SP", oFira10Reg,, AZUL)
    oPrint:say(nLinha += 10, 320, PadL("E-MAIL: edison.antonio@totvs.com.br", 56), oFira10Bold,, AZUL)
    oPrint:say(nLinha += 10, 320, PadL("TELEFONE: (19) 99318 • 9130", 56), oFira10Reg,, AZUL)
    oPrint:say(nLinha += 10, 320, PadL("CPF: (informação sigilosa, contate a empresa)", 56), oFira10Reg,, AZUL)


    // Linha para dividir o início de tudo do cabeçalho inicial.
    oPrint:Line(120, 15, 120, 580,, '-6')
Return

Static Function Top(cAlias)
    local cString := DtoC(Date())
    nLinha := 140

    oPrint:Say(nLinha, 15, "Pedido de Venda: " + alltrim((cAlias)->(C5_NUM)), oFira15,, AZUL)
    oPrint:Say(nLinha, 15, PadL("Data: " + cString, 80.5), oFira15,, AZUL)

    nLinha += 10
    oPrint:Line(nLinha, 15, nLinha, 580,, '-6')

Return

Static Function Cliente(cAlias)
    nLinha := 160

    oPrint:Say(nLinha,       015, "Cliente  :", oFira12Bold,, AZUL)
    oPrint:Say(nLinha,       075, alltrim((cAlias)->(A1_NOME)), oFira12Reg,, VERMELHO)

    oPrint:Say(nLinha,       350, "Bairro   :", oFira12Bold,, AZUL)
    oPrint:say(nLinha,       410, alltrim((cAlias)->(A1_BAIRRO)), oFira12Reg,, VERMELHO)

    oPrint:Say(nLinha += 10, 015, "E-Mail   :", oFira12Bold,, AZUL)
    oPrint:Say(nLinha,       075, alltrim((cAlias)->(A1_EMAIL)), oFira12Reg,, VERMELHO)

    oPrint:Say(nLinha,       350, "CEP      :", oFira12Bold,, AZUL)
    oPrint:say(nLinha,       410, alltrim((cAlias)->(A1_CEP)), oFira12Reg,, VERMELHO)

    oPrint:Say(nLinha += 10, 015, "Endereço :", oFira12Bold,, AZUL)
    oPrint:Say(nLinha,       075, alltrim((cAlias)->(A1_END)), oFira12Reg,, VERMELHO)

    oPrint:Say(nLinha,       350, "I.E.     :", oFira12Bold,, AZUL)
    oPrint:say(nLinha,       410, alltrim((cAlias)->(A1_INSCR)), oFira12Reg,, VERMELHO)

    oPrint:Say(nLinha += 10, 015, "Cidade   :", oFira12Bold,, AZUL)
    oPrint:Say(nLinha,       075, alltrim((cAlias)->(A1_MUN)), oFira12Reg,, VERMELHO)

    oPrint:Say(nLinha += 10, 015, "TEL      :", oFira12Bold,, AZUL)
    oPrint:Say(nLinha,       075, alltrim((cAlias)->(A1_TEL)), oFira12Reg,, VERMELHO)
    
    oPrint:Say(nLinha += 10, 015, "CNPJ/CPF :", oFira12Bold,, AZUL)
    oPrint:Say(nLinha,       075, alltrim((cAlias)->(A1_CGC)), oFira12Reg,, VERMELHO)

Return

Static Function Info(cAlias)
    local cString       := ""
    local nBottom       := 0
    local nTotal        := 0
    
    DbSelectArea(cAlias)
    (cAlias)->(DbGoTop())

    nLinha      += 10
    oPrint:Box(nLinha, 15, 240, 580, "-8")
    oPrint:Line(nLinha, 50, 240, 50,, "-8")
    oPrint:Line(nLinha, 150, 240, 150,, "-8")
    oPrint:Line(nLinha, 300, 240, 300,, "-8")
    oPrint:Line(nLinha, 330, 240, 330,, "-8")
    oPrint:Line(nLinha, 360, 240, 360,, "-8")
    oPrint:Line(nLinha, 430, 240, 430,, "-8")
    oPrint:Line(nLinha, 500, 240, 500,, "-8")

    oPrint:Say(nLinha += 13,    017,    "ITEM",         oFira12Bold,, AZUL)
    oPrint:Say(nLinha,          055,    "CÓDIGO",       oFira12Bold,, AZUL)
    oPrint:Say(nLinha,          155,    "DESCRIÇÃO",    oFira12Bold,, AZUL)
    oPrint:Say(nLinha,          305,    "U.M.",         oFira12Bold,, AZUL)
    oPrint:Say(nLinha,          335,    "QTD.",         oFira12Bold,, AZUL)
    oPrint:Say(nLinha,          365,    "VLR. UNIT.",   oFira12Bold,, AZUL)
    oPrint:Say(nLinha,          435,    "VLR. TOTAL",   oFira12Bold,, AZUL)
    oPrint:Say(nLinha,          505,    "DATA ENTREGA", oFira12Bold,, AZUL)

    nLinha += 20

    While (cAlias)->(!EoF())
        Final(nLinha)

        oPrint:Say(nLinha, 17, alltrim((cAlias)->(C6_ITEM)), oFira8Reg,, VERMELHO)

        cString := Alltrim((cAlias)->(C6_PRODUTO))
        QuebraCorpo(cString, 30, 55)

        cString := Alltrim((cAlias)->(C6_DESCRI))
        QuebraCorpo(cString, 30, 155)

        oPrint:Say(nLinha, 305, alltrim((cAlias)->(C6_UM)), oFira8Reg,, VERMELHO)

        oPrint:Say(nLinha, 335, cValToChar((cAlias)->(C6_QTDVEN)), oFira8Reg,, VERMELHO)

        oPrint:Say(nLinha, 365, cValToChar((cAlias)->(C6_PRCVEN)), oFira8Reg,, VERMELHO)

        oPrint:Say(nLinha, 435, cValToChar((cAlias)->(C6_VALOR)), oFira8Reg,, VERMELHO)

        cString := DtoC(StoD((cAlias)->(C6_ENTREG)))
        oPrint:Say(nLinha, 505, cString, oFira8Reg,, VERMELHO)

        nLinha += 20

        nTotal += (cAlias)->(C6_VALOR)

        IncProc()
        (cAlias)->(DbSkip())
    End do

    nBottom := nLinha
    oPrint:Line(nBottom, 15, nBottom, 580,, "-8")
    oPrint:Line(220, 15, nBottom, 15,, "-8")
    oPrint:Line(220, 50, nBottom, 50,, "-8")
    oPrint:Line(220, 150, nBottom, 150,, "-8")
    oPrint:Line(220, 300, nBottom, 300,, "-8")
    oPrint:Line(220, 330, nBottom, 330,, "-8")
    oPrint:Line(220, 360, nBottom, 360,, "-8")
    oPrint:Line(220, 430, nBottom, 430,, "-8")
    oPrint:Line(220, 500, nBottom, 500,, "-8")
    oPrint:Line(220, 580, nBottom, 580,, "-8")

    // Valor Frete
    oPrint:Box(nBottom + 10, 150, nBottom + 30, 330, "-8")

    // Valor Total
    oPrint:Box(nBottom + 10, 430, nBottom + 30, 580, "-8")

    // Valor Despesa
    oPrint:Box(nBottom + 30, 150, nBottom + 50, 330, "-8")

    // Linhas separadoras
    oPrint:Line(nBottom + 10, 240, nBottom + 50, 240,, "-8")
    oPrint:Line(nBottom + 10, 500, nBottom + 30, 500,, "-8")

    oPrint:Say(nBottom + 23, 155, "Valor Frete: ",  oFira12Bold,, AZUL)
    oPrint:Say(nBottom + 23, 245, "R$ " + cvaltochar((cAlias)->(C5_FRETE)), oFira10Reg,, VERMELHO)


    oPrint:Say(nBottom + 23, 435, "Total: ",        oFira12Bold,, AZUL)
    oPrint:Say(nBottom + 23, 505, "R$ " + cvaltochar(nTotal), oFira12Reg,, VERMELHO)

    oPrint:Say(nBottom + 43, 155, "Valor Despesa: ", oFira12Bold,, AZUL)
    oPrint:Say(nBottom + 43, 245, "R$ " + cvaltochar((cAlias)->(C5_DESPESA)), oFira10Reg,, VERMELHO)

Return

Static Function Bottom(cAlias)
    nLinha := 650

    // Caixa de informações gerais.
    oPrint:Box(nLinha,   15, 750, 580, "-8")
    oPrint:Say(nLinha += 10, 240, "INFORMAÇÕES GERAIS", oFira15,, AZUL)

    oPrint:Say(nLinha += 10,    030, "Forma de Pagamento:", oFira12Bold,, AZUL)
    oPrint:Say(nLinha,          140, alltrim((cAlias)->(C5_CONDPAG)) + " - " + alltrim((cAlias)->(E4_DESCRI)), oFira12Reg,, VERMELHO)

    oPrint:Say(nLinha += 10,    030, "Transportadora    :", oFira12Bold,, AZUL)
    oPrint:Say(nLinha,          140, alltrim((cAlias)->(C5_TRANSP)), oFira12Reg,, VERMELHO)

    oPrint:Say(nLinha += 10,    030, "Espécie           :", oFira12Bold,, AZUL)
    oPrint:Say(nLinha,          140, alltrim((cAlias)->(C5_ESPECI1)), oFira12Reg,, VERMELHO)

    oPrint:Say(nLinha += 10,    030, "Volume            :", oFira12Bold,, AZUL)
    oPrint:Say(nLinha,          140, alltrim((cAlias)->(C5_VOLUME1)), oFira12Reg,, VERMELHO)

    oPrint:Say(nLinha += 10,    030, "Descontos %       :", oFira12Bold,, AZUL)
    oPrint:Say(nLinha,          140, alltrim((cAlias)->(C5_DESC1)), oFira12Reg,, VERMELHO)

    oPrint:Say(nLinha += 10,    030, "Tipo de Frete     :", oFira12Bold,, AZUL)
    oPrint:Say(nLinha,          140, alltrim((cAlias)->(C5_TPFRETE)), oFira12Reg,, VERMELHO)

    oPrint:Say(nLinha += 10,    030, "Vendedor          :", oFira12Bold,, AZUL)
    oPrint:Say(nLinha,          140, "Edison Cake", oFira12Reg,, VERMELHO)

    oPrint:Say(nLinha += 10,    030, "Validade          :", oFira12Bold,, AZUL)
    oPrint:Say(nLinha,          140, "Indeterminado.", oFira12Reg,, VERMELHO)

    // Caixa final de mensagem.
    nLinha := 760
    oPrint:Box(nLinha,   15,    790, 580, "-8")
    oPrint:Say(nLinha += 17,    30, "Mensagem: ", oFira15,, AZUL)
    oPrint:Say(nLinha,          140, "Emitido com FwMsPrinter.", oFira12Reg,, VERMELHO)

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
            oPrint:Say(nLinha, nColuna, cText, oFira8Reg,, VERMELHO)
            nLinha += 10
        Next
    else
        oPrint:Say(nLinha, nColuna, cString, oFira8Reg,, VERMELHO)
    endif

    if lQuebra
        nLinha -= (nLinhas * 10)
    endif

Return

Static Function Final(nLinhaFinal)
    if nLinha > 610
        oPrint:EndPage()
        oPrint:StartPage()

            Inicio()
        Top(cAlias)
        Cliente(cAlias)
        Info(cAlias)
        Bottom(cAlias)

        nLinha := LINHA_1
        Top(cAlias)
    endif
Return
