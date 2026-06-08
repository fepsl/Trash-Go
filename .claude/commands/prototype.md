# Prototype

Você vai construir **código descartável** para responder a uma pergunta de design específica antes de qualquer implementação de produção.

## A pergunta decide o formato

Antes de escrever uma linha: **qual pergunta esse protótipo precisa responder?**

| Pergunta | Formato do protótipo |
|---|---|
| "Essa lógica de negócio funciona?" | App de terminal interativo — teste a máquina de estados e os casos de borda |
| "Essa UI faz sentido?" | Variações visuais acessíveis por uma única rota, togláveis |

Se a pergunta não for clara, pare e pergunte ao usuário antes de continuar.

## Regras inegociáveis

1. **Marque como temporário** — coloque o arquivo perto do código-alvo com nome explícito (`prototype-`, `spike-`, `temp-`)
2. **Um comando para rodar** — sem setup complexo, sem dependências externas desnecessárias
3. **Estado em memória** — sem banco de dados, sem persistência
4. **Sem testes, sem tratamento de erro, sem abstrações** — é código descartável por design
5. **Exiba o estado completo após cada interação** — as mudanças devem ser visíveis

## Ao terminar

Quando o protótipo responder a pergunta:
1. Documente o aprendizado em forma durável (mensagem de commit, ADR, comentário no CLAUDE.md)
2. **Delete o protótipo** — não deixe código de spike no repositório

O objetivo é capturar o aprendizado, não manter o código.
