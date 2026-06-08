Você vai criar um **PRD (Product Requirements Document)** completo e estruturado com base no que o usuário descreveu.

## Processo

1. Se o usuário ainda não descreveu o que quer construir, pergunte: "Descreva a feature ou produto que quer especificar."
2. Se já há descrição, prossiga direto para a escrita do PRD.

## Estrutura do PRD

Escreva o PRD no arquivo `docs/prd-[nome-da-feature].md` com a seguinte estrutura:

```markdown
# PRD: [Nome da Feature]

**Status**: Rascunho  
**Data**: [data atual]  
**Autor**: Desenvolvedor

---

## 1. Contexto e Problema

[Por que estamos construindo isso? Qual dor ou oportunidade estamos endereçando?]

## 2. Objetivos

- **Objetivo principal**: [o que queremos alcançar]
- **Métricas de sucesso**: [como vamos medir que deu certo]
- **Fora de escopo**: [o que não será feito nesta versão]

## 3. Usuários e Personas

| Persona | Necessidade | Como essa feature ajuda |
|---------|------------|------------------------|
| [USER]  | ...        | ...                    |
| [ADMIN] | ...        | ...                    |

## 4. Requisitos Funcionais

### RF-01: [Nome do requisito]
**Como** [persona], **quero** [ação], **para que** [benefício]

**Critérios de aceite:**
- [ ] [critério 1]
- [ ] [critério 2]

[Repetir para cada requisito funcional]

## 5. Requisitos Não-Funcionais

| Categoria     | Requisito                           |
|---------------|-------------------------------------|
| Performance   | ...                                 |
| Segurança     | ...                                 |
| Disponibilidade| ...                                |

## 6. Design Técnico (alto nível)

### Endpoints afetados
[Liste os endpoints HTTP que serão criados ou modificados]

### Mudanças no banco de dados
[Liste tabelas novas, colunas novas, migrations necessárias]

### Impacto em outros módulos
[O que mais pode ser afetado]

## 7. Riscos e Dependências

| Risco | Probabilidade | Impacto | Mitigação |
|-------|--------------|---------|-----------|
| ...   | Alta/Média/Baixa | Alto/Médio/Baixo | ... |

## 8. Plano de Testes

- [ ] Testes unitários: [o que cobrir]
- [ ] Testes de integração: [cenários críticos]
- [ ] Teste manual: [fluxo principal a validar]

## 9. Critérios de Done (DoD)

- [ ] Todos os critérios de aceite implementados e testados
- [ ] Cobertura de testes adequada
- [ ] Documentação atualizada
- [ ] Code review aprovado
- [ ] Funciona no Docker Compose local
```

Após criar o arquivo, informe o caminho e pergunte se quer ajustar alguma seção ou avançar para `/prd-to-issues`.
