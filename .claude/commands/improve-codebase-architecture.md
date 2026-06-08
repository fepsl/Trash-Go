Você vai analisar o codebase e identificar **oportunidades de melhoria arquitetural**, priorizando por impacto.

## Processo de análise

### 1. Leitura do contexto
Leia os arquivos principais do projeto para entender a arquitetura atual:
- `CLAUDE.md` — princípios e decisões técnicas
- Todos os `@Service` — regras de negócio
- Todos os `@Controller` — interface da API
- `GlobalExceptionHandler` — tratamento de erros
- Migrations Flyway — modelo de dados

### 2. Análise por dimensão

Para cada dimensão abaixo, identifique problemas reais — não hipotéticos:

#### Separação de responsabilidades
- Existe lógica de negócio no controller?
- O service acessa o repositório de forma adequada?
- Existem entidades JPA sendo retornadas diretamente nos controllers?

#### Consistência de padrões
- Todos os services seguem o mesmo padrão de tratamento de erro?
- Os DTOs são consistentes (request/response separados)?
- A injeção de dependência é sempre por construtor?

#### Módulos rasos (shallow modules)
- Alguma classe/método faz muito pouco e poderia ser inlined?
- Alguma abstração foi criada sem necessidade real?

#### Módulos profundos (deep modules que deveriam ser expostos)
- Algum service tem responsabilidades demais?
- Existe lógica duplicada entre services?
- Algum método faz coisas demais e deveria ser extraído?

#### Segurança
- Endpoints administrativos têm `@PreAuthorize` correto?
- Senhas ou dados sensíveis expostos em logs ou respostas?
- Validações em todos os pontos de entrada (DTOs com Bean Validation)?

#### Performance (potencial)
- Queries N+1 sem `@EntityGraph` ou `JOIN FETCH`?
- Dados carregados desnecessariamente (EAGER onde deveria ser LAZY)?
- Ausência de índices para filtros frequentes?

### 3. Priorização

Para cada problema encontrado, classifique:

| Severidade | Critério |
|-----------|---------|
| 🔴 Crítico | Viola princípio arquitetural fundamental ou introduz risco de segurança |
| 🟡 Importante | Dificulta manutenção ou esconde bugs potenciais |
| 🟢 Melhoria | Deixaria o código mais limpo/legível sem urgência |

### 4. Apresentação dos resultados

Para cada problema encontrado:

```
🔴/🟡/🟢 [TÍTULO DO PROBLEMA]

Arquivo: `caminho/do/arquivo.java` (linha X)
Problema: [descrição do que está errado]
Por quê importa: [impacto concreto]
Solução: [como corrigir, com exemplo de código se necessário]
```

### 5. Plano de ação

Após listar todos os problemas, pergunte:
"Deseja que eu corrija os problemas 🔴 críticos agora, ou prefere revisar tudo primeiro?"

Se autorizado, aplique as correções **uma por vez**, explicando cada mudança.

---

## O que NÃO reportar

- Preferências estilísticas sem impacto real
- Abstrações que "poderiam" ser úteis no futuro
- Refatorações que aumentam complexidade sem benefício claro
- Qualquer coisa que já esteja documentada como decisão intencional no `CLAUDE.md`
