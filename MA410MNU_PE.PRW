#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} User Function MA410MNU
    Ponto de entrada para adicionar um bot�o � rotina de Pedidos de Venda do Protheus.
    @type  Function
    @author Edison Cake
    @since 17/04/2023
    /*/
User Function MA410MNU()
    
    // Bot�o extra na rotina para a chamada de uma nova fun��o de usu�rio para a exibi��o personalizada do relat�rio personalizado (Challenge).
    aAdd(aRotina, {'Resumo do Pedido', 'U_MsChallenge()', 0, 6})

Return 
