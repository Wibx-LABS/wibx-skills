# Manual: Golang Pro Skill

---

#### 🇺🇸 English
**What it does:**
This skill turns Claude into a senior Go developer with deep expertise in Go 1.21+, concurrent programming, and cloud-native microservices. Use it when building Go applications that need concurrency, microservice architecture, or production-grade performance.

**Key Features:**
- **Six-Step Workflow:** Analyze architecture → design small composed interfaces → implement with proper error handling and context propagation → lint (`golangci-lint`, fix everything) → optimize with pprof and benchmarks → test table-driven with `-race`.
- **Gates Between Steps:** `go vet ./...` before moving past implementation, zero lint issues before optimizing, race detector green before committing. The gates are the point — they catch what review misses.
- **Concurrency Done Right:** Bounded goroutine lifetime via `context`, error propagation with `%w`, no goroutine leaks on cancellation. The reference pattern demonstrates all three at once.
- **Loaded on Demand:** Detailed guidance lives in `references/` — concurrency, interfaces, generics, testing, project structure — and only the relevant file is read.
- **Explicit Do / Don't:** No ignored errors, no panic for normal error handling, no goroutine without a lifecycle, no hardcoded configuration. Functional options or env vars instead.
- **Contracts First:** Output is interface definitions, then implementation with proper package structure, then table-driven tests, then a brief note on the concurrency patterns used.

**Triggers on:** Go, Golang, goroutines, channels, gRPC, Go generics, concurrent programming, Go interfaces, CLI tools, benchmarks, table-driven testing.

---

#### 🇧🇷 Português
**O que faz:**
Esta skill transforma o Claude num desenvolvedor Go sênior com domínio profundo de Go 1.21+, programação concorrente e microsserviços cloud-native. Use ao construir aplicações Go que precisam de concorrência, arquitetura de microsserviços ou performance de produção.

**Principais Recursos:**
- **Workflow de Seis Passos:** Analisar arquitetura → desenhar interfaces pequenas e compostas → implementar com tratamento de erro adequado e propagação de contexto → lintar (`golangci-lint`, corrigindo tudo) → otimizar com pprof e benchmarks → testar table-driven com `-race`.
- **Portões Entre os Passos:** `go vet ./...` antes de passar da implementação, zero problema de lint antes de otimizar, race detector verde antes de commitar. Os portões são o ponto — pegam o que a revisão deixa passar.
- **Concorrência Bem Feita:** Vida útil de goroutine limitada por `context`, propagação de erro com `%w`, zero vazamento de goroutine no cancelamento. O padrão de referência demonstra os três de uma vez.
- **Carregado sob Demanda:** A orientação detalhada vive em `references/` — concorrência, interfaces, generics, testes, estrutura de projeto — e só o arquivo relevante é lido.
- **Faça / Não Faça Explícito:** Nada de erro ignorado, nada de panic para erro normal, nada de goroutine sem ciclo de vida, nada de configuração hardcoded. Functional options ou variáveis de ambiente no lugar.
- **Contratos Primeiro:** A saída é definição de interfaces, depois implementação com estrutura de pacote adequada, depois arquivo de teste table-driven, depois uma nota curta sobre os padrões de concorrência usados.

**Dispara em:** Go, Golang, goroutines, channels, gRPC, generics de Go, programação concorrente, interfaces Go, ferramentas CLI, benchmarks, testes table-driven.
