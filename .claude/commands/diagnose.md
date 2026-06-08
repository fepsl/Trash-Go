# Diagnose

Você vai debugar o problema descrito seguindo uma metodologia estruturada de seis fases. **Não tente resolver antes de entender.**

## Fase 1 — Construa um loop de feedback

Antes de qualquer outra coisa, crie um sinal de falha rápido, determinístico e executável:
- Um teste unitário que falha de forma reproduzível
- Um script `curl` ou CLI que demonstra o comportamento errado
- Um endpoint de teste ou log específico que evidencia o sintoma

**Se você tiver um sinal rápido e determinístico, vai encontrar a causa.**

## Fase 2 — Reproduza

Confirme que o loop criado produz exatamente o sintoma relatado — sempre, não às vezes.

Se não reproduzir de forma consistente: documente as condições de ocorrência e siga em frente.

## Fase 3 — Formule hipóteses

Gere **3 a 5 hipóteses falsificáveis**, ordenadas por probabilidade, **antes** de testar qualquer uma.

Para cada hipótese, escreva:
- O que ela implica
- Como provar ou descartar com uma observação

Não teste hipóteses ao acaso.

## Fase 4 — Instrumente

Para cada hipótese (da mais provável para a menos):
- Use logs pontuais, debugger ou ferramenta de observabilidade
- Mude **uma variável por vez**
- Descarte a hipótese ou confirme-a com evidência concreta

Evite o instinto de "jogar código no problema" — instrumente primeiro.

## Fase 5 — Corrija e adicione teste de regressão

1. Escreva primeiro o teste que cobre o caso falho (na camada arquitetural correta)
2. Aplique a correção mínima necessária
3. Confirme que o teste passa e que o loop de feedback original está verde

## Fase 6 — Limpeza e post-mortem

- Remova toda instrumentação de debug (logs temporários, endpoints de teste)
- Verifique que o problema original está resolvido
- Documente em uma linha o que teria prevenido esse bug (no commit ou no PR)
