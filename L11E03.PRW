#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} User Function MT120BRW
    Ponto de Entrada da Rotina MATA121 (Exerc�cio 03) para a inclus�o de um bot�o personalizado na rotina.
    @type  Function
    @author Edison Cake
    @since 14/04/2023
    /*/
User Function MT120BRW()
    
    aAdd(aRotina, {'MsPrinter - Pedido',    'U_MsResumo()', 0, 6}) // Bot�o do Exerc�cio 03, com as informa��es isoladas de um pedido s�.
    aAdd(aRotina, {'MsPrinter - Todos',     'U_MsTotvs()', 0, 6})     // Bot�o do Exerc�cio 05, com as informa��es detalhadas de todos os pedidos.

Return 

