#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} User Function MA410MNU
    Ponto de entrada para adicionar um botão à rotina de Pedidos de Venda do Protheus.
    @type  Function
    @author Edison Cake
    @since 17/04/2023
    /*/
User Function MA410MNU()
    
    // Botão extra na rotina para a chamada de uma nova função de usuário para a exibição personalizada do relatório personalizado (Challenge).
    aAdd(aRotina, {'Resumo do Pedido', 'U_MsChallenge()', 0, 6})

Return 
