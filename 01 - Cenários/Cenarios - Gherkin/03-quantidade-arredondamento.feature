# language: pt
@ui @calculo
Funcionalidade: Quantidade máxima, arredondamento e consistência dos valores
  Como cliente da Verzel Store
  Quero ver valores corretos e consistentes no carrinho
  Para confiar no total da minha compra

  Contexto:
    Dado que estou na Verzel Store com o carrinho vazio

  @TC011 @CA10
  Cenário: Limite de 5 unidades por produto
    Dado que tenho 5 unidades do produto "P003" no carrinho
    Então o subtotal é "R$ 949,50"
    E o frete é "R$ 0,00"
    E o total é "R$ 949,50"
    Quando tento adicionar uma 6ª unidade do produto "P003"
    Então a 6ª unidade é impedida
    E o carrinho permanece com 5 unidades do produto "P003"

  @TC012 @CA11
  Cenário: Valores arredondados para 2 casas decimais
    Dado que tenho 3 unidades do produto "P001" no carrinho
    Quando aplico o cupom "BEMVINDO10"
    Então o subtotal é "R$ 179,70"
    E o desconto é "R$ 17,97"
    E o frete é "R$ 19,90"
    E o total é "R$ 181,63"
    E nenhum valor exibido tem mais de 2 casas decimais

  @TC013 @ui @api
  Cenário: Os valores da tela são iguais aos calculados pela API
    Dado que tenho 1 unidade do produto "P002" no carrinho
    E que tenho 2 unidades do produto "P004" no carrinho
    E que apliquei o cupom "BEMVINDO10"
    Quando envio os mesmos itens e o mesmo cupom para o cálculo da API
    Então o subtotal da tela e da API é "R$ 239,70"
    E o desconto da tela e da API é "R$ 23,97"
    E o frete da tela e da API é "R$ 0,00"
    E o total da tela e da API é "R$ 215,73"
