# WIBX SKILLs

<p align="center">
  <pre>
  _____________  __.___.____    .____       _________
 /   _____/    |/ _|   |    |   |    |     /   _____/
 \_____  \|      < |   |    |   |    |     \_____  \ 
 /        \    |  \|   |    |___|    |___  /        \
/_______  /____|__ \___|_______ \_______ \/_______  /
        \/        \/           \/       \/        \/ 
  </pre>
  <strong>O Hub Central para Skills de IA da Wibx</strong>
</p>

> Uma coleção abrangente de skills de IA especializadas, projetadas para aumentar a produtividade, automatizar fluxos de trabalho e padronizar as capacidades de IA em todos os departamentos da Wiboo.

---

## 🚀 Visão Geral

Este repositório serve como a fonte oficial de verdade para skills de IA em toda a empresa. Seja para o jurídico, marketing, engenharia ou produto, cada skill aqui é construída para ser modular, reutilizável e facilmente integrada em nossos ecossistemas de agentes (Forge/Bifrost).

## 📦 Skills Principais

Cada skill neste repositório é organizada em sua própria pasta, contendo o pacote `.skill` e um arquivo `MANUAL.md`.

| Nome da Skill | Pasta | Descrição | Status |
| :--- | :--- | :--- | :--- |
| **Wibx Presentations** | [`/presentations`](./presentations) | Skill especializada para gerar e refinar apresentações corporativas. | `Ativo` |

## 🛠 Como Usar

### 🧩 Instalação no Claude

Para instalar e usar estas skills no Claude Desktop:

1. **Baixe a Skill**: Localize o arquivo `.skill` na pasta da skill desejada.
2. **Abra as Configurações do Claude**: No Claude Desktop, navegue até **Settings > Skills**.
3. **Importar**: Clique em **"Add Skill"** e faça o upload do arquivo `.skill`.
4. **Verificar**: A skill agora deve estar ativa e pronta para uso em suas conversas.

> [!NOTE]
> Se você estiver usando o Claude.ai (Web), você pode extrair o arquivo `.skill` (é um arquivo ZIP) e copiar o conteúdo do `SKILL.md` para as **Instruções Personalizadas do seu Projeto** (Project Custom Instructions).

### 💻 Uso Geral

1. **Clone o Repositório**: Certifique-se de ter as skills mais recentes localmente.
   ```bash
   git clone https://github.com/Wibx-LABS/wibx-skills.git
   ```
2. **Importar Skill**: Importe o arquivo `.skill` desejado para o seu ambiente de agente (Forge, Bifrost ou Claude).
3. **Manuais**: Verifique o arquivo `MANUAL.md` dentro de cada pasta de skill para instruções de uso e recursos específicos.

## 🤝 Contribuindo

Estamos constantemente expandindo nossa biblioteca de skills! Se você criou uma skill que pode beneficiar outras equipes:

1. Crie uma nova branch para sua skill.
2. Adicione o arquivo `.skill` à pasta apropriada.
3. Atualize este `README.md` com os detalhes da nova skill.
4. Envie um Pull Request para revisão pela equipe Wibx Labs.

---

<p align="center">
  <strong>Construído e mantido pela equipe Wibx Labs. Apenas para uso interno.</strong>
</p>
