Você vai transformar o PRD em **tarefas práticas e verticais** prontas para implementação.

## Processo

1. Leia o PRD mais recente em `docs/` (ou o que o usuário indicar).
2. Decomponha em tasks seguindo os princípios abaixo.
3. Salve as tasks em `docs/tasks-[nome-da-feature].md`.

## Princípios de decomposição

**Vertical slices**: cada task deve entregar valor observável — não "criar model" e depois "criar service" separados. Prefira "implementar cadastro de produto com validações (model + service + controller + teste)".

**Relações de bloqueio**: identifique qual task bloqueia qual. Ex: "configurar Flyway migration" bloqueia "implementar endpoints do produto".

**Tamanho**: cada task deve ser completável em 1-4 horas de desenvolvimento focado.

## Formato do arquivo de tasks

```markdown
# Tasks: [Nome da Feature]

> Gerado a partir de: [[prd-[nome].md]]  
> Data: [data atual]

---

## Dependências entre tasks
[Diagrama texto das relações de bloqueio]
TASK-01 → TASK-02 → TASK-04
TASK-03 → TASK-04

---

## TASK-01 — [Título]

**Tipo**: `feat` | `fix` | `test` | `refactor` | `chore`  
**Estimativa**: [horas]  
**Bloqueia**: TASK-XX  
**Bloqueada por**: —  

**O que fazer:**
- [ ] [ação concreta 1]
- [ ] [ação concreta 2]

**Arquivos afetados:**
- `backend/src/main/java/com/ecommerce/model/Foo.java` (criar)
- `backend/src/main/resources/db/migration/V3__foo.sql` (criar)

**Critério de done:**
- [ ] Teste unitário passa
- [ ] `docker-compose up` sobe sem erros
- [ ] Endpoint responde corretamente no Swagger

---

[Repetir para cada task]
```

## Ordem de apresentação

1. Tasks de infraestrutura/banco (migrations, configs)
2. Tasks de modelo e domínio
3. Tasks de serviço e regra de negócio
4. Tasks de controller e API
5. Tasks de frontend
6. Tasks de teste e qualidade

Após criar o arquivo, mostre o resumo das tasks com estimativas totais e sugira por qual começar.
