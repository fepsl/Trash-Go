Você vai implementar a funcionalidade descrita pelo usuário seguindo **TDD estrito** (Test-Driven Development).

## Ciclo obrigatório: Red → Green → Refactor

Você DEVE seguir o ciclo na ordem exata. Não pule etapas.

---

## Passo 1 — RED (escrever o teste que falha)

1. Pergunte ao usuário (se não estiver claro): "O que exatamente precisa ser implementado? Qual o comportamento esperado?"
2. Escreva **apenas** o teste — nenhuma implementação ainda.
3. O teste deve:
   - Estar em `src/test/java/com/ecommerce/service/` (para services) ou `controller/` (para controllers com `@WebMvcTest`)
   - Usar JUnit 5 + Mockito
   - Ter nome descritivo: `nomeDoMetodo_cenario_resultadoEsperado()`
   - Cobrir o **caminho feliz** primeiro, depois casos de erro
4. Confirme: "O teste foi escrito. Ele vai falhar porque a implementação não existe. Posso prosseguir?"

---

## Passo 2 — GREEN (mínimo código para passar)

1. Escreva a **implementação mínima** para o teste passar — sem otimizações, sem código extra.
2. Siga a arquitetura do projeto:
   - Regra de negócio sempre no `@Service`
   - Controller só recebe, delega e responde
   - Entidades nunca retornadas diretamente — usar DTOs
   - Injeção por construtor com `@RequiredArgsConstructor`
3. Execute mentalmente o teste e confirme que ele passaria.
4. Informe: "Implementação mínima pronta. O teste deve passar agora."

---

## Passo 3 — REFACTOR (melhorar sem quebrar)

1. Revise o código escrito e identifique:
   - Duplicação que pode ser extraída
   - Nomes que podem ser mais expressivos
   - Código que viola os princípios do projeto (ver CLAUDE.md)
   - Oportunidades de simplificação
2. Aplique as melhorias **sem alterar comportamento** (os testes continuam passando).
3. Apresente o diff e explique cada melhoria.

---

## Passo 4 — Cobrir casos de erro

Após o caminho feliz:
- Escreva testes para cada exceção customizada relevante (`ResourceNotFoundException`, `InsufficientStockException`, etc.)
- Repita o ciclo Red → Green para cada caso

---

## Regras do projeto a respeitar

- Exceções customizadas para cada caso de erro de negócio (pacote `exception/`)
- Formato de erro padronizado via `GlobalExceptionHandler`
- `@PreAuthorize("hasRole('ADMIN')")` para endpoints administrativos
- Testes de service usam `@ExtendWith(MockitoExtension.class)` e mocam o repositório
- Testes de controller usam `@WebMvcTest` + `@MockBean` para o service

---

Ao final, apresente um resumo: quantos testes escritos, o que foi implementado e sugestões de testes adicionais que aumentariam a confiança.
