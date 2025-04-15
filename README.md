# Projeto de Arquitetura e Organização de Computadores II

## 📄 Descrição do Projeto

Este repositório contém a transformação da implementação em VHDL de um processador **MIPS Monociclo** para uma arquitetura **MIPS Pipeline**:

- **MIPS Monociclo**: Implementação de referência que executa uma instrução por ciclo de clock.
- **MIPS Pipeline**: Versão modificada da arquitetura monociclo, agora com suporte a pipeline, permitindo a execução de múltiplas instruções simultaneamente em diferentes estágios.

O projeto inclui também a simulação bem-sucedida do algoritmo **Bubble Sort** utilizando o software **ModelSim**, demonstrando a funcionalidade prática da arquitetura pipeline implementada.

Este trabalho foi desenvolvido como parte da disciplina de **Arquitetura e Organização de Computadores II**, sob a orientação do professor **Mateus Beck Rutzig**, cujos ensinamentos foram fundamentais para o sucesso deste projeto.


---

## 📁 Estrutura do Projeto

<details>
📁 Estrutura do Projeto

```text
MIPS-VHDL/
├── monociclo/        # Implementação do processador MIPS Monociclo
│   ├── asm/          # Códigos em Assembly utilizados para simulações
│   ├── sim/          # Arquivos de simulação específicos do monociclo
│   └── src/          # Módulos VHDL do processador monociclo
│
├── pipeline/         # Implementação do processador MIPS com Pipeline
│   ├── sim/          # Arquivos de simulação específicos do pipeline
│   ├── src/          # Módulos VHDL do processador pipeline
│   └── work/         # Diretório de trabalho do ModelSim

  
---

</details> ```

## ✨ Destaques do Projeto

### ✅ Simulação do Bubble Sort no ModelSim

- Implementação completa do algoritmo Bubble Sort em assembly MIPS.
- Conversão para código de máquina e carregamento na memória de instruções.
- Simulação bem-sucedida demonstrando a ordenação de um array de números.
- Captura de waveforms no ModelSim comprovando o funcionamento correto.

---

## 🔧 Funcionalidades Implementadas

### 🟦 MIPS Pipeline

- 5 estágios pipeline: IF, ID, EX, MEM, WB.
- Detecção e tratamento de *hazards*.
- Unidade de *forwarding* para *hazards* de dados.
- Controle de *stalls* para *hazards* de controle.

---

## ▶️ Como Executar

### 🔹 Requisitos

- **ModelSim** (ou outro simulador compatível com VHDL).
- Conhecimento básico de VHDL.

### 🔹 Passos para Simulação do Bubble Sort

1. Carregue os arquivos VHDL no ModelSim.
2. Compile todos os componentes na ordem correta.
3. Execute o testbench `MIPS_monocycle_tb.vhd`.
4. Adicionei o arquivo mipspipe.do para visualizar as waveforms
5. Analise as waveforms para verificar a ordenação.

---

## 🙏 Agradecimentos

Gostaria de expressar meus sinceros agradecimentos ao professor **Mateus Beck Rutzig** por sua orientação excepcional durante o desenvolvimento deste projeto. 

Também quero agradecer ao colega **Bruno Henrique Spies** que me ajudou a desenvolver esse projeto sempre explicando e ensinando em cada etapa que eu tinha dificuldade.

---

## 📬 Contato

**[Arthur Montero Portella]**  
**[arthur.portella@ecomp.ufsm.br]** 

---

Sinta-se à vontade para explorar o código, especialmente a implementação do **Bubble Sort** e suas **waveforms** no ModelSim. Contribuições e sugestões são sempre bem-vindas!
