# language: pt
@ui @frete
Funcionalidade: Frete grátis
  Como cliente da Verzel Store
  Quero ganhar frete grátis em compras maiores
  Para pagar menos nas minhas compras

  Contexto:
    Dado que estou na Verzel Store com o carrinho vazio

  @TC007 @CA07
  Cenário: Compra abaixo de R$ 200,00 cobra frete fixo
    Dado que tenho 1 unidade do produto "P001" no carrinho
    Quando consulto o resumo do carrinho
    Então o frete é "R$ 19,90"
    E o total é "R$ 79,80"
    E o carrinho informa que faltam "R$ 140,10" para o frete grátis

  @TC008 @CA06 @CA07
  Cenário: Frete grátis quando o subtotal é exatamente R$ 200,00
    Dado que tenho 1 unidade do produto "P005" no carrinho
    E que o carrinho informa que faltam "R$ 100,00" para o frete grátis
    Quando altero a quantidade do produto "P005" para 2
    Então o subtotal é "R$ 200,00"
    E o frete é "R$ 0,00"
    E o total é "R$ 200,00"
    E o aviso de valor faltante para o frete grátis deixa de ser exibido

  @TC008 @CA07
  Cenário: O aviso de frete grátis volta ao reduzir o subtotal abaixo de R$ 200,00
    Dado que tenho 2 unidades do produto "P005" no carrinho
    Quando altero a quantidade do produto "P005" para 1
    Então o frete é "R$ 19,90"
    E o carrinho informa que faltam "R$ 100,00" para o frete grátis

  @TC009 @CA07
  Cenário: Subtotal logo abaixo do limite ainda cobra frete
    Dado que tenho 1 unidade do produto "P002" no carrinho
    E que tenho 1 unidade do produto "P001" no carrinho
    Quando consulto o resumo do carrinho
    Então o subtotal é "R$ 199,80"
    E o frete é "R$ 19,90"
    E o total é "R$ 219,70"
    E o carrinho informa que faltam "R$ 0,20" para o frete grátis

  @TC010 @CA08
  Cenário: O frete grátis considera o subtotal antes do desconto do cupom
    # Subtotal de R$ 200,00 garante o frete grátis, mesmo que o total com desconto fique abaixo disso
    Dado que tenho 2 unidades do produto "P005" no carrinho
    Quando aplico o cupom "BEMVINDO10"
    Então o desconto é "R$ 20,00"
    E o frete é "R$ 0,00"
    E o total é "R$ 180,00"
