#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} User Function MT120BRW
    Ponto de Entrada da Rotina MATA121 (Exercício 03) para a inclusão de um botão personalizado na rotina.
    @type  Function
    @author Edison Cake
    @since 14/04/2023
    /*/
User Function MT120BRW()
    
    aAdd(aRotina, {'MsPrinter - Pedido',    'U_MsResumo()', 0, 6}) // Botào do Exercício 03, com as informaçòes isoladas de um pedido só.
    aAdd(aRotina, {'MsPrinter - Todos',     'U_MsTotvs()', 0, 6})     // Botào do Exercício 05, com as informaçòes detalhadas de todos os pedidos.

Return 

