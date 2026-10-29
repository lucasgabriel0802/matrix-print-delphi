# MatrixPrint for Delphi

<p align="center">
  <img src="https://img.shields.io/badge/Delphi-10.1%20Berlin%20%7C%2010.2%20%7C%2010.3%20%7C%2010.4%20%7C%2011%20%7C%2012-blue.svg" alt="Delphi Versions" />
  <img src="https://img.shields.io/badge/Platform-Win32%20%7C%20Win64-lightgrey.svg" alt="Platform" />
  <img src="https://img.shields.io/badge/Dependencies-Pure%20VCL%20(Zero%20DLLs)-brightgreen.svg" alt="Pure VCL" />
  <img src="https://img.shields.io/badge/PRs-Welcome-orange.svg" alt="PRs Welcome" />
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License MIT" />
</p>

**MatrixPrint** é uma biblioteca e suíte de componentes de código aberto desenvolvida para **Delphi** (compatível do Delphi 10.1 Berlin ao Delphi 12 Athens) focada em relatórios matriciais, comprovantes, formulários contínuos e impressão de texto puro em alta velocidade.

Desenvolvida com foco em simplicidade, consistência e modernidade, a biblioteca não requer DLLs externas, instaladores pesados ou dependências de terceiros: tudo funciona sobre a **VCL nativa e WinAPI**.

---

## ✨ Recursos em Destaque

- **Zero Dependências Externas:** Construído 100% em Object Pascal puro sobre a VCL e WinAPI padrão (`WinSpool`, `Printers`, `Vcl.Graphics`). Sem dependência de DLLs, runtimes C++ ou frameworks pesados.
- **Motor de Impressão Híbrido:**
  - **RAW Spooler Direto:** Envio de texto e sequências de escape diretamente ao spooler do Windows via `WinSpool` para impressoras matriciais (como Epson LX-300, LX-350, FX-890) e térmicas não fiscais, com suporte a emulação **ESC/P (Epson)** e **PCL (HP)**.
  - **Renderização Gráfica GDI (`TPrinter.Canvas`):** Impressão vetorial limpa e consistente em fontes monoespaçadas para impressoras jato de tinta, laser, térmicas modernas ou impressoras virtuais.
- **Gerador Nativo de PDF:**
  - Cria arquivos `.pdf` diretamente da matriz de texto em Pascal puro, sem precisar de Ghostscript, PDFTK ou utilitários externos instalados no cliente.
- **Visualizador de Impressão (Preview VCL Nativo):**
  - Fiel ao formato clássico de **papel contínuo com remalina lateral e furos de tração**.
  - Efeito de **linhas zebradas** configurável para relatórios financeiros e contábeis extensos.
  - Controle dinâmico de Zoom (50% a 200%).
  - Caixa de busca de texto (*Find*) com realce visual dos termos localizados.
  - Cópia integral do texto da página para a Área de Transferência do Windows (*Clipboard*).
  - Exportação direta de dentro da janela para **PDF** ou **TXT**.
- **Diálogo de Configuração de Impressora Integrado:** Diálogo nativo VCL para seleção de impressora do Windows, driver/emulação, intervalo de páginas e cópias.
- **API Limpa e Tipada:** Ciclo de vida idiomático inspirado no `TPrinter` (`BeginDoc`, `EndDoc`, `NewPage`), com métodos sobrecarregados de alinhamento (`Print`, `PrintCenter`, `PrintRight`) e desenho de caixas e linhas divisórias (`PrintBox`, `PrintLine`).

---

## 📁 Estrutura do Projeto

```text
MatrixPrint/
├── Demo/                    # Aplicação de demonstração completa
│   ├── DemoMatrixPrint.dpr  # Projeto executável de exemplo
│   ├── U_DemoMain.pas       # Rotinas com relatórios de 80 e 132 colunas
│   └── U_DemoMain.dfm       # Tela de testes e exportações
├── Packages/                # Pacotes de instalação do Delphi
│   ├── MatrixPrintRT.dpk    # Runtime Package
│   └── MatrixPrintDT.dpk    # DesignTime Package (Paleta 'MatrixPrint')
├── Source/                  # Código-fonte da suíte
│   ├── MatrixPrint.Types.pas        # Tipos, enums tipográficos, TMatrixCell, configurações
│   ├── MatrixPrint.Engine.pas       # Motores RAW Spooler, GDI, exportador PDF e TXT
│   ├── MatrixPrint.Setup.pas / .dfm # Diálogo de configuração de impressão VCL
│   ├── MatrixPrint.Preview.pas / .dfm # Tela de preview de formulário contínuo
│   ├── MatrixPrint.pas              # Componente principal TMatrixPrint
│   └── MatrixPrint.Reg.pas          # Registro do componente na paleta da IDE
├── LICENSE                  # Licença MIT
└── README.md                # Este documento
```

---

## 📦 Como Instalar no RAD Studio / Delphi

1. **Adicionar ao Library Path:**
   - No Delphi, acesse: **Tools** ➔ **Options...**
   - Navegue até: **Environment Options** ➔ **Delphi Options** ➔ **Library**.
   - Em **Selected connection/platform**, selecione **32-bit Windows**.
   - No campo **Library path**, clique em `[...]` e adicione o caminho absoluto da pasta `Source`:
     ```text
     C:\DELPHI_COMPONENT_BERLIN\MatrixPrint\Source
     ```
   - Clique em **Add** ➔ **OK** ➔ **Save**.

2. **Compilar o Pacote Runtime:**
   - Abra o arquivo `Packages\MatrixPrintRT.dpk`.
   - No *Project Manager*, clique com o botão direito sobre ele e selecione **Compile** (ou **Build**).

3. **Instalar o Pacote DesignTime:**
   - Abra o arquivo `Packages\MatrixPrintDT.dpk`.
   - Clique com o botão direito e selecione **Install**.
   - O Delphi exibirá a confirmação de que o componente **`TMatrixPrint`** foi registrado na paleta de componentes **MatrixPrint**.

---

## 🚀 Exemplo Rápido de Uso (Quick Start)

### 1. Criando um Relatório em Tempo de Execução

```pascal
uses
  MatrixPrint.Types,
  MatrixPrint;

procedure EmitirComprovante;
var
  Report: TMatrixPrint;
begin
  Report := TMatrixPrint.Create(nil);
  try
    // Configuração de dimensões (80 colunas e 66 linhas por folha)
    Report.TotalColumns := 80;
    Report.TotalLines   := 66;
    Report.LinesPerInch := lpi6; // 6 linhas por polegada

    // Inicia a montagem do documento em memória
    Report.BeginDoc;
    try
      // Cabeçalho centralizado com negrito
      Report.PrintCenter(1, 'MINHA EMPRESA DE SERVICOS LTDA', [mteBold]);
      Report.PrintCenter(2, 'COMPROVANTE DE ENTREGA E FATURAMENTO');
      Report.Print(3, 1, 'Data: ' + FormatDateTime('dd/mm/yyyy hh:nn', Now));
      Report.PrintRight(3, 'Folha: 1/1');
      Report.PrintLine(4, 1, 80, '=');

      // Tabela de Itens
      Report.Print(5, 1, 'ITEM  DESCRICAO                            QTD   VLR.UNIT     TOTAL', [mteBold]);
      Report.PrintLine(6, 1, 80, '-');

      Report.Print(7, 1, '001   SERVICO DE SUPORTE TECNICO ESPECIAL   01     150,00    150,00');
      Report.Print(8, 1, '002   MANUTENCAO PREVENTIVA MENSAL          02      85,00    170,00');
      Report.PrintLine(9, 1, 80, '-');

      // Totais à direita
      Report.Print(10, 45, 'VALOR TOTAL:', [mteBold]);
      Report.PrintRight(10, 'R$ 320,00', [mteBold, mteExpanded]);

      // Moldura de rodapé
      Report.PrintBox(12, 1, 15, 80);
      Report.PrintCenter(13, 'Declaramos ter recebido os servicos constantes neste documento.');
      Report.PrintCenter(14, 'Assinatura: __________________________________________________');
    finally
      // Encerra a montagem do documento
      Report.EndDoc;
    end;

    // Opções de saída disponíveis:
    Report.ShowPreview;                       // Abre a janela de visualização gráfica
    // Report.PrintDirect;                    // Envia direto para a impressora configurada
    // Report.ExportToPDF('C:\Temp\Doc.pdf'); // Salva em arquivo PDF vetorial
    // Report.ExportToText('C:\Temp\Doc.txt'); // Salva em arquivo de texto puro
  finally
    Report.Free;
  end;
end;
```

---

## 🔤 Efeitos Tipográficos Disponíveis

Os efeitos visuais são configurados de maneira tipada através do conjunto `TMatrixTextEffects`:

| Efeito | Identificador Pascal | Descrição |
| :--- | :--- | :--- |
| **Negrito** | `mteBold` | Caracteres com traço reforçado / impacto duplo |
| **Itálico** | `mteItalic` | Texto inclinado |
| **Sublinhado** | `mteUnderline` | Traço na base inferior dos caracteres |
| **Expandido** | `mteExpanded` | Largura dobrada (ótimo para títulos e totais) |
| **Condensado Padrão** | `mteCondensed17` | Densidade aproximada de 17.1 CPI (~132 colunas) |
| **Elite (12 CPI)** | `mteCondensed12` | Densidade intermediária (~96 colunas) |
| **Ultra Condensado** | `mteCondensed20` | Densidade máxima de 20 CPI (~160 colunas) |

Exemplo de uso combinado:
```pascal
Report.Print(5, 1, 'AVISO URGENTE', [mteBold, mteExpanded]);
```

---

## 🖥️ Emulações e Drivers Suportados

Na propriedade `Driver` (ou no diálogo interativo de setup), é possível escolher:

- **`mdEpsonEscP`**: Padrão ESC/P e ESC/P2 para impressoras matriciais Epson (LX-300, LX-350, FX-890, LQ, etc.) e compatíveis.
- **`mdHPPcl`**: Padrão PCL para impressoras jato de tinta e laser HP / compatíveis.
- **`mdGenericText`**: Envio de texto limpo em modo RAW sem comandos de escape especiais.
- **`mdWindowsGDI`**: Renderização vetorial universal em Canvas monoespaçado (`TPrinter.Canvas`), funcionando em qualquer impressora instalada no Windows.

---

## 🤝 Quer contribuir? Envie um Pull Request!

Contribuições da comunidade são **muito bem-vindas**! Se você encontrou um bug, tem uma ideia de melhoria, deseja adicionar suporte a novas emulações ou aperfeiçoar o visual do preview:

1. Faça um **Fork** deste repositório.
2. Crie uma branch para sua funcionalidade ou correção:
   ```bash
   git checkout -b feature/minha-melhoria
   ```
3. Faça o commit das suas alterações explicando o que foi feito:
   ```bash
   git commit -m "feat(preview): adiciona atalho para exportar diretamente para CSV"
   ```
4. Envie a branch para o seu repositório remoto:
   ```bash
   git push origin feature/minha-melhoria
   ```
5. Abra um **Pull Request (PR)** detalhado aqui no GitHub. Vamos analisar e mesclar com o maior prazer!

---

## ☕ Apoie o Projeto (Buy Me a Coffee)

Se o **MatrixPrint** te ajudou, economizou seu tempo ou resolveu problemas de impressão legada no seu sistema, considere apoiar o projeto com um café via Pix! Toda ajuda é muito bem-vinda e incentiva a continuidade da manutenção e criação de novos recursos abertos para a comunidade Delphi:

<p align="center">
  <b>Chave Pix (E-mail):</b><br/>
  <code>lucasgabriel0802@gmail.com</code>
</p>

---

## 📄 Licença

Distribuído sob a licença **MIT**. Você tem liberdade para utilizar, modificar e distribuir este componente tanto em projetos pessoais quanto comerciais sem custos de licenciamento. Consulte o arquivo [LICENSE](LICENSE) para mais detalhes.
