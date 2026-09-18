# Mythborn — Documento de Gameplay

## 1. Visão Geral

Mythborn é um roguelite de sobrevivência em arena, em visão 2D top-down, no ritmo de jogos como Brotato. O jogador controla um macaco aparentemente comum que, ao longo da progressão narrativa, descobre ser Sun Wukong, o Rei Macaco. O universo pode reunir elementos de diferentes mitologias, mas com identidade visual, narrativa e mecânica própria.

Esta etapa cobre a primeira implementação de referência de um personagem completo — **Sun Wukong** — com evolução por nível, uma build livre construída via uma loja de upgrades unificada, e uma moeda temporária de run (Essência). Ainda com placeholders visuais, sem arte definitiva e sem os sistemas narrativos completos.

## 2. Pilares do Gameplay

- **Ação automática, decisão estratégica**: o jogador não mira nem atira manualmente; as decisões relevantes são movimentação/posicionamento e escolha de upgrades.
- **Builds livres por partida**: cada corrida gera uma combinação diferente de armas e melhorias.
- **Progressão em duas camadas**: progressão permanente/narrativa (entre partidas) + build livre (dentro da partida).
- **Simplicidade legível**: sistemas simples, de fácil leitura visual, mesmo com muitos inimigos e efeitos na tela.

## 3. Controles

- Movimento: **WASD**, ou joystick virtual (toque ou mouse) — 8 direções.
- Sem mira manual: ataques são automáticos.
- Navegação em menus (Menu Principal, Level Up, Pause, Configurações, Game Over): mouse ou toque, todos os botões respondem a ambos.

## 4. Movimento

- Personagem controlado via `CharacterBody2D`, com vetor de entrada normalizado permitindo as 8 direções.
- Velocidade base modificável por upgrades permanentes e de partida.
- Colisão com os limites da arena (paredes simples).

## 5. Combate Automático

- O jogador nunca mira: cada arma equipada ataca sozinha, de forma independente, seguindo seu próprio cooldown.
- Regra de alvo: **cada arma procura o inimigo válido mais próximo dela** dentro do seu alcance e o usa como alvo no momento do ataque.
- Se não houver inimigo dentro de alcance, a arma aguarda o próximo ciclo de cooldown sem atacar.

## 6. Seleção do Inimigo Mais Próximo

- Todo inimigo pertence ao grupo `enemies`.
- O sistema de targeting (compartilhado por todas as armas) varre os inimigos vivos e retorna o mais próximo da posição da arma, respeitando o alcance máximo daquela arma.
- Esse sistema é centralizado para que novas armas só precisem informar posição e alcance — sem duplicar lógica de busca de alvo.

## 7. Sistema de Armas

- Cada arma é uma cena independente com um script que estende uma base comum (`Weapon`), responsável por: cooldown, busca de alvo, e delegar o efeito do ataque (melee, projétil, área, etc.) para a implementação específica.
- Dados de cada arma (dano, cooldown, alcance, nome) ficam em um `Resource` (`WeaponData`), permitindo balancear ou criar variações sem alterar código.
- Upgrades permanentes e de partida (dano, velocidade de ataque) afetam todas as armas do jogador via multiplicadores centralizados, não por arma individual.

### REGRA OFICIAL: Duplicatas e Fusão

**Uma mesma arma pode existir em várias cópias.** Cada cópia é uma instância independente (seu próprio cooldown, seu próprio nível) e ocupa 1 dos **12 slots totais** — o limite é de **instâncias**, não de tipos diferentes de arma.

Exemplo válido: `12x Ruyi Jingu Bang Lv.1` é uma build completa e legítima, `12/12`.

Comprar uma arma que o jogador já tem **nunca** vira upgrade automático — é sempre uma cópia nova e independente. A única forma de uma cópia subir de nível é a **fusão**, uma ação **opcional e nunca automática**:

- Exige **2 cópias da mesma arma, no mesmo nível** (`Ruyi Lv.1 + Ruyi Lv.1 → Ruyi Lv.2`). Não é possível fundir níveis diferentes nem armas diferentes.
- É **gratuita** (não consome Essência).
- Consome as 2 cópias e produz 1 cópia no nível seguinte — **libera 1 slot** (12 armas → 1 fusão → 11 armas).
- O jogador decide se e quando fundir; pode manter todas as cópias separadas indefinidamente se preferir.

Exemplo completo: com `12x Ruyi Lv.1` (12/12), o jogador funde uma vez → `10x Lv.1 + 1x Lv.2` (11/12) → compra uma arma nova → `10x Lv.1 + 1x Lv.2 + 1x Fagulha Divina` (12/12) → decide fundir mais duas `Lv.1` → `8x Lv.1 + 2x Lv.2 + 1x Fagulha` (11/12). Cada decisão é do jogador.

### Nível das Armas

Cada arma tem `current_level` e um `max_level` (padrão 5). O nível muda de verdade o dano, o cooldown e (opcionalmente) o alcance — os valores exatos de crescimento são configuráveis por arma. Ao atingir o nível máximo, a UI mostra **MAX** e a fusão para aquele nível deixa de ser oferecida — mas o jogador pode continuar tendo várias cópias no nível máximo.

### Armas Implementadas

- **Ruyi Jingu Bang** (Bastão de Sun Wukong): corpo a corpo, alcance curto, dano direto, com um arco de golpe visível e flash de impacto no alvo. Arma inicial de Wukong.
- **Clones de Pelo**: poder característico de Wukong, desbloqueado ao evoluir para SUN WUKONG. Atinge até 2 inimigos próximos por ciclo — pequenos "ataques adicionais" simultâneos ao Bastão.
- **Fagulha Divina**: arma de longo alcance à base de projétil, deliberadamente **sem vínculo com nenhuma mitologia específica** — prova de que a build de Wukong não fica presa a poderes chineses (ver seção "Personagem e Build" abaixo). Desbloqueada ao atingir SUN WUKONG DESPERTADO, ou comprável antes disso na loja.

Todas podem coexistir no inventário em qualquer quantidade e nível, cada cópia com seu próprio cooldown e alcance, todas usando o mesmo sistema de targeting.

### Pickup Magnet (Coleta de XP)

O jogador tem um raio de coleta (padrão 80px, configurável). Uma gema de XP fora do raio fica parada; ao entrar no raio, ela acelera suavemente em direção ao jogador até ser coletada por contato — nunca teleporta. A passiva **Magnetismo** aumenta esse raio.

## 8. Experiência (XP)

- Inimigos derrotados soltam um item de XP na posição da morte.
- O jogador coleta o XP ao tocar o item (colisão simples via `Area2D`).
- XP acumulado é somado a uma barra de experiência exibida na interface.

## 9. Level-Up

- Ao atingir o XP necessário, o jogador sobe de nível.
- A ação do jogo é pausada temporariamente.
- O jogador ganha Essência (moeda da run) e um "token" de escolha grátis.
- Se o nível atingido corresponde a uma evolução de personagem (ver seção 10), primeiro aparece a **Tela de Evolução**; só depois disso abre a **Loja de Upgrades**.
- Caso contrário, a Loja de Upgrades abre diretamente.
- O requisito de XP para o próximo nível cresce a cada nível.

## 10. Personagem e Evolução — Sun Wukong

O primeiro personagem jogável completo do Mythborn é **Sun Wukong**, com três estágios ao longo da run:

| Estágio | Nível | Nome exibido | Ganhos |
|---|---|---|---|
| Inicial | 1+ | WUKONG | — |
| Evoluído | 15 | SUN WUKONG | +25% vida, +10% velocidade, +15% dano, desbloqueia **Clones de Pelo** |
| Despertado | 30 | SUN WUKONG DESPERTADO | +20% vida, +15% velocidade, +25% dano, +15% velocidade de ataque, desbloqueia **Fagulha Divina** |

Ao atingir um desses níveis, o jogo mostra uma tela de evolução simples (nome antigo → novo nome, ganhos, novo poder) antes de voltar ao fluxo normal. Os bônus de evolução são multiplicadores separados dos bônus de upgrades da loja — os dois se acumulam sem conflitar.

**Importante**: Sun Wukong não fica limitado a poderes chineses. A Fagulha Divina, por exemplo, é deliberadamente uma arma sem mitologia associada — a build da run pode incluir qualquer combinação de armas/poderes, futuramente de qualquer panteão (Zeus, Anúbis, Thor, Hades...), independente da origem do personagem.

## 11. Loja Unificada de Upgrades

Ao subir de nível, a Loja de Upgrades reúne em uma única tela rolável, do topo para baixo:

- **CABEÇALHO**: nível atual, Essência, estágio do personagem e tempo de run.
- **OFERTAS**: até 4 ofertas sorteadas em grade — armas, passivas ou poderes, cada uma com ícone, categoria, descrição, preço e um botão de **cadeado** (🔒/🔓) para travar a oferta contra o reroll.
- **SUA BUILD**: passivas/poderes à esquerda, armas à direita — armas agrupadas por nome e nível (ex.: `Ruyi Jingu Bang Lv.1 × 5`), com um botão **FUNDIR** ao lado de qualquer grupo com 2+ cópias no mesmo nível (pede confirmação antes de aplicar).
- **STATS**: resumo dos atributos atuais do personagem (vida máxima, velocidade, dano, velocidade de ataque, raio de coleta, XP ganho), lido direto de `PlayerStats` — nunca um número recalculado à parte.

O jogador pode comprar **múltiplas ofertas na mesma visita** (enquanto tiver Essência) e fundir armas da build quantas vezes quiser, tudo na mesma tela. Um botão **REROLL** gera um novo conjunto de ofertas por um custo crescente — ofertas travadas (🔒) sobrevivem ao reroll, só as destravadas são sorteadas de novo. Só fecha manualmente pelo botão **CONTINUAR** — o jogo permanece pausado até lá.

A primeira compra de cada visita à loja é sempre gratuita (consome o "token" ganho ao subir de nível), então subir de nível nunca é frustrante mesmo com pouca Essência acumulada.

**Preços sobem com o uso**: cada compra paga (não a gratuita do token) encarece as próximas ofertas e o próprio reroll em ~12%, cumulativo pelo resto da run — evita que o mesmo item custe sempre igual do início ao fim, mesmo com a Essência entrando cada vez mais rápido.

### Comprar vs. Fundir — Nunca a Mesma Coisa

- **Comprar uma arma** (nova ou já possuída) = sempre uma cópia nova e independente no nível 1. O botão mostra **NOVA CÓPIA** quando o jogador já tem aquela arma, só para deixar claro o que vai acontecer — nunca é rotulado como fusão.
- **Fundir** = ação separada, feita na seção "Sua Build", nunca disparada por uma compra.
- **Melhorar uma passiva** = comprar a mesma passiva de novo aumenta o nível dela (ex.: `Dano Lv.2 → Lv.3`) — passivas não têm cópias múltiplas, só 1 nível que sobe.

### Regras de Oferta

- Armas **sempre podem ser oferecidas novamente**, mesmo já possuídas — duplicatas são o comportamento desejado. Só ficam desabilitadas (com o motivo explicado, ex. "Inventário de armas cheio") quando o inventário está no limite de 12; fundir uma arma existente libera espaço imediatamente para a oferta voltar a ficar disponível.
- Uma passiva que já atingiu o nível máximo nunca é oferecida de novo (mostra **MAX** no resumo da build).
- Nenhuma oferta repete o mesmo item na mesma tela.

## 12. Essência (Economia da Run)

- Moeda temporária, existe apenas durante a run atual — não é salva entre partidas.
- Ganha derrotando inimigos e ao subir de nível (bônus fixo + o token de compra grátis).
- Gasta na Loja de Upgrades (compras e reroll).
- Não confundir com progressão permanente: isso ainda não existe no Mythborn.

## 13. Passivas e Poderes de Wukong

Diferente de armas, uma passiva **não tem múltiplas instâncias** — é sempre "1 passiva + 1 nível", com um `max_level` (padrão 3). Comprar a mesma passiva de novo sobe o nível; ao atingir o máximo, ela para de aparecer na loja.

Passivas disponíveis nesta etapa:

- **Dano**, **Velocidade de Ataque**, **Velocidade**, **Vida Máxima**, **XP Ganho**, **Magnetismo** (raio de coleta de pickups).
- **Nuvem Ventania**: poder característico de Wukong, mecanicamente uma passiva de velocidade de movimento (categoria "Poder" na loja, por ser a marca de Wukong).

Um upgrade novo é apenas uma entrada de dados a mais — nenhuma dessas passivas exigiu tocar na tela de compra.

## 14. Progressão Narrativa

- Fora do escopo desta etapa a implementação completa, mas a arquitetura deve permitir, futuramente:
  - Desbloqueio gradual da identidade de Sun Wukong.
  - Eventos ou marcos narrativos entre partidas.
  - Novas armas/poderes mitológicos associados a essa progressão.

## 15. Progressão Permanente (Meta-Progressão)

Diferente da Essência (que reseta a cada run), o Mythborn agora tem uma segunda economia que **persiste entre partidas**: **Fragmentos Míticos**.

- Ganhos ao final de toda run (proporcional a tempo sobrevivido + nível alcançado) e por recompensas específicas (derrotar um chefe, desbloquear uma conquista).
- Gastos na tela **PROGRESSÃO** (acessível pelo Menu Principal) em **melhorias permanentes**: hoje, *Poder Ancestral* (+2% de dano por nível, até 5) e *Vitalidade Ancestral* (+2% de vida máxima por nível, até 5). Cada nível custa mais que o anterior.
- Aplicadas automaticamente no início de toda nova run (não é preciso reaplicar manualmente).
- Salvos em disco (`user://meta_progress.cfg`) — sobrevivem a fechar e abrir o jogo de novo.

## 15.1 Localidades

Onde a run acontece. Nesta etapa existem duas:

- **Domínio Chinês**: inimigos comuns (Grunt), três "ondas" de intensidade crescente ao longo do tempo (spawn mais rápido conforme a run avança) e um chefe, o **Rei Touro Demônio**, que aparece aos 5 minutos de sobrevivência.
- **Domínio Grego**: inimigo próprio (Sátiro Selvagem, mais rápido e mais frágil que o Grunt), duas ondas, sem chefe ainda — existe principalmente para comprovar que trocar de localidade realmente muda o conteúdo da run (inimigos e ritmo diferentes), não só o nome mostrado na tela.

A arquitetura já suporta quantas localidades forem necessárias (cada uma com seu próprio conjunto de inimigos, ondas e chefes).

## 15.2 Modos e Desafios

- **Survival**: o modo padrão. Depois de 15 minutos (o "ciclo principal"), entra automaticamente em **Endless** — a dificuldade (vida, dano e velocidade de spawn dos inimigos) continua subindo indefinidamente, a run nunca termina sozinha.
- **Endless**: mesma escalada, mas já ativa desde o início da run.
- **Desafio "Inferno"**: +50% de vida nos inimigos, -20% de XP, recompensa 50% maior. Um desafio nunca é código específico — é só uma combinação de multiplicadores.

Personagem, skin, localidade, modo e desafio são escolhidos antes de cada run, num fluxo de telas pelo Menu Principal (ver seção 20).

## 15.3 Chefe

O **Rei Touro Demônio** aparece aos 5 minutos de sobrevivência no Domínio Chinês. Reaproveita 100% do sistema de inimigo comum (perseguição, dano de contato, vida, targeting) — só adiciona nome, barra de vida própria no HUD e uma recompensa ao morrer (Essência + Fragmentos Míticos + desbloqueia a skin "Wukong Dourado").

## 15.4 Conquistas

Seis conquistas nesta etapa (cinco visíveis, uma secreta):

- **Primeiro Sangue** — derrote um inimigo.
- **Em Ascensão** — alcance o nível 2.
- **O Rei Macaco** — evolua para Sun Wukong.
- **Caçador de Lendas** — derrote um chefe.
- **Sobrevivente** — sobreviva 5 minutos numa run.
- 🔒 secreta: **Despertar Precoce** — alcance o Despertar em menos de 5 minutos.

Cada uma concede uma recompensa (Fragmentos Míticos e, em um caso, uma skin) assim que a condição é satisfeita — não é preciso reivindicar manualmente. Consulte a lista completa (com o que já foi desbloqueado) na tela **CONQUISTAS** do Menu Principal.

## 15.5 Skins

Uma skin não altera atributos, só aparência (hoje, uma cor sobre o sprite do personagem). A primeira skin do jogo, **Wukong Dourado**, é desbloqueada ao derrotar o Rei Touro Demônio pela primeira vez, e passa a ser usada automaticamente em toda run seguinte.

## 16. Estrutura Básica de uma Partida

1. Jogador entra na arena.
2. Inimigos começam a spawnar periodicamente e perseguem o jogador.
3. Armas equipadas atacam automaticamente os inimigos mais próximos.
4. Inimigos derrotados soltam XP.
5. Jogador coleta XP e sobe de nível, escolhendo melhorias.
6. O ciclo se repete, com inimigos surgindo continuamente, até a morte do jogador (fim de partida).

## 17. Tipos Iniciais de Inimigos

- **Inimigo Básico (Grunt)**: sem ataque à distância, persegue o jogador em linha reta e causa dano por contato. Vida, velocidade, dano de contato e XP concedido são definidos via dado (`EnemyData`), preparando o terreno para novos tipos apenas com novos dados/cenas.
- **Rei Touro Demônio** (chefe, ver seção 15.3): mesmo comportamento do Grunt, só que muito mais forte, com nome/vida próprios no HUD e recompensa ao morrer.

A dificuldade de todo inimigo (vida, dano, velocidade) escala automaticamente com o tempo de run e o modo/desafio ativos (ver seção 15.2) — nenhum número fica fixo no spawner.

## 18. Escopo do Protótipo

Incluído nesta etapa:

- Movimento do jogador em 8 direções.
- Uma arena simples e fechada.
- Um tipo de inimigo com spawn contínuo.
- Sun Wukong como personagem jogável, com evolução em 3 estágios (WUKONG → SUN WUKONG → SUN WUKONG DESPERTADO).
- Três armas/poderes (Ruyi Jingu Bang, Clones de Pelo, Fagulha Divina) coexistindo no mesmo inventário.
- Sistema de vida e dano (jogador e inimigos).
- Sistema de XP, level-up, evolução de personagem e Loja Unificada de Upgrades (armas, passivas e poderes, com reroll).
- Essência como moeda temporária da run.
- Inventário de armas preparado para até 12 armas — **duplicatas são o comportamento desejado** (ver seção 7), com fusão voluntária.
- Interface mínima (vida, XP, nível, timer, Essência, estágio do personagem, armas atuais, barra de vida do chefe quando ativo).
- Estrutura completa de navegação: Menu Principal (com Coleção, Progressão e Conquistas funcionais), fluxo de seleção de Personagem/Skin/Localidade/Modo/Desafio antes de toda run, Pause (com Configurações e saída confirmada, sem sobreposição de telas), Game Over organizado em seções, e reinício limpo da partida.
- Duas localidades (Domínio Chinês com chefe, Domínio Grego sem chefe) com ondas de intensidade crescente.
- Modos Survival (transição automática para Endless) e Endless (escalada desde o início), ambos selecionáveis; arquitetura pronta para Challenge/Boss Rush/Chaos.
- Desafio "Inferno" selecionável.
- Skin "Wukong Dourado" selecionável/equipável de verdade (não só desbloqueável).
- Seis conquistas com recompensa automática; meta-progressão (Fragmentos Míticos, melhorias permanentes, skins) salva em disco.

## 19. Fluxo Global do Jogo

O jogo agora tem uma estrutura de navegação completa, não apenas a arena:

```
MENU PRINCIPAL
   ↓ (JOGAR)
PARTIDA (PLAYING)
   ↓ (sobe de nível)                      ↓ (botão de pause)
nível de evolução? ─sim→ EVOLUÇÃO         PAUSE
   │não                     ↓ (continuar)    ↓ (continuar)
   ↓                     LOJA DE UPGRADES     │
   └──────────────────→ (compra/reroll) ──────┘
                            ↓ (continuar)
PARTIDA (PLAYING)  ←────────┘
   ↓ (morte do jogador)
GAME OVER / RESULTADOS
   ↓                    ↓
JOGAR NOVAMENTE     MENU PRINCIPAL
```

Estados possíveis (`GameManager.State`): `MAIN_MENU`, `PLAYING`, `EVOLUTION`, `UPGRADE_SHOP`, `PAUSED`, `GAME_OVER`. Evolução, Loja de Upgrades e Pause são três pausas conceitualmente diferentes (duas automáticas por progressão, uma manual pedida pelo jogador), mas todas usam o mesmo mecanismo de pausa da engine e o mesmo caminho de retorno (`resume_gameplay()`). Apenas um estado de UI principal fica ativo por vez — nunca duas telas de pausa sobrepostas.

## 20. Menu Principal

Tela inicial do jogo (`MainMenu.tscn`), com:

- Título "MYTHBORN".
- Botão **JOGAR** — abre o fluxo de seleção da run (ver seção 20.1).
- Botão **CONFIGURAÇÕES** — abre o painel de configurações por cima do menu.
- Botão **COLEÇÃO** — hub somente-leitura com abas Personagens / Skins / Localidades / Bosses / Conquistas, mostrando "???" para o que ainda não foi descoberto/desbloqueado.
- Botão **PROGRESSÃO** — melhorias permanentes pagas em Fragmentos Míticos.
- Botão **CONQUISTAS** — lista de conquistas com progresso.

### 20.1 Fluxo de Início de Run

Ao apertar JOGAR, o jogador passa por uma sequência de telas antes da partida começar:

```
PERSONAGEM → SKIN → LOCALIDADE → MODO → DESAFIO → RESUMO → (COMEÇAR) → PARTIDA
```

Cada tela mostra as opções disponíveis (com as ainda bloqueadas exibindo "🔒" e o motivo) e reaproveita o mesmo componente visual de seleção — só o conteúdo muda. "Voltar" em qualquer etapa retorna à etapa anterior; no Resumo, revê tudo o que foi escolhido (personagem, skin, localidade, modo, desafio) antes de confirmar. Cada escolha já é aplicada imediatamente aos sistemas reais (não é só um texto na tela) — a run que começa usa exatamente o que foi selecionado.

## 21. Pause

Acessível durante a partida por um botão discreto no canto superior direito do HUD. Ao pausar:

- todo o gameplay congela (inimigos, timer, ataques, movimentação, ganho de XP) — o mesmo mecanismo de pausa usado na Evolução e na Loja de Upgrades;
- é exibido um painel com **CONTINUAR**, **CONFIGURAÇÕES** e **SAIR DA PARTIDA**;
- ao abrir **CONFIGURAÇÕES**, o painel de Pause fica completamente oculto (nunca as duas telas desenhadas ao mesmo tempo); **VOLTAR** retorna ao Pause, nunca direto ao gameplay;
- **SAIR DA PARTIDA** pede confirmação antes de descartar a corrida atual e voltar ao Menu Principal — o jogador nunca sai de uma partida ativa sem confirmar.

## 22. Configurações

Painel reutilizável (mesma cena instanciada no Menu Principal e no Pause), com três opções realmente funcionais:

- **Som**: muta/desmuta o bus de áudio `SFX`.
- **Música**: muta/desmuta o bus de áudio `Music`.
- **Vibração**: liga/desliga o disparo de vibração do aparelho (usado hoje como feedback ao tomar dano).

As preferências são salvas em `user://settings.cfg` e persistem entre sessões.

## 23. Game Over e Resultados

Ao morrer, o jogador vê imediatamente a tela de Game Over, organizada em três seções (nunca uma parede de texto só):

- **RESULTADO DA RUN**: personagem/estágio, localidade, modo, desafio, tempo sobrevivido, nível, inimigos/chefes derrotados, Essência total ganha, armas e passivas/poderes da build final.
- **RECOMPENSA PERMANENTE**: quantos Fragmentos Míticos essa run rendeu de verdade (já soma qualquer recompensa de chefe/conquista ganha durante ela, sem duplicar).
- **NOVOS DESBLOQUEIOS** (só aparece se houver algo): conquistas e skins desbloqueadas durante essa run específica.

Dali, pode escolher **JOGAR NOVAMENTE** (inicia uma corrida nova e limpa) ou **MENU PRINCIPAL**.

## 24. Estatísticas da Partida

Dados temporários da corrida atual (não persistem entre partidas) ficam centralizados e são reiniciados a cada nova run: tempo sobrevivido, inimigos derrotados, nível alcançado, upgrades escolhidos, armas possuídas (incluindo duplicatas e níveis) e nível de cada passiva.

## 25. Assets Visuais Básicos

Os placeholders geométricos (retângulos/polígonos coloridos) foram substituídos por sprites simples e originais, gerados via código (sem uso de assets de terceiros): o macaco Wukong, o bastão Ruyi Jingu Bang, o inimigo Grunt e a gema de XP. Ainda é um estilo de "protótipo polido", não arte final — mas já dá uma primeira identidade visual reconhecível. Ver `assets/` e `docs/ARCHITECTURE.md` para onde cada um fica.

## 26. Funcionalidades Planejadas para Etapas Futuras

- Novos personagens (Zeus, Hades, Thor, Anúbis...) com aparência própria — a seleção/progressão/evolução já funcionam para qualquer `CharacterData` novo, só falta um segundo `Visual`/sprite por personagem (hoje `Player.tscn` só tem o de Wukong).
- Mais armas/poderes de outras mitologias na build de qualquer personagem.
- Evolução de arma além do nível máximo (ex.: Ruyi Jingu Bang Lv.5 + condição → "Ascended") — o nivelamento e a fusão em si já existem, só falta esse próximo estágio.
- Mais localidades e mais chefes (a arquitetura de `LocationData`/`WaveData`/`BossData`, incluindo fases de chefe, já suporta), e o Domínio Grego ganhando seu próprio chefe.
- Progressão narrativa completa.
- Mais conquistas e mais skins (a tela de seleção de skin já existe e funciona para qualquer quantidade).
- Relíquias (categoria já reservada na loja, sem conteúdo ainda).
- Bosses secretos de verdade e a cadeia "Quatro Cavaleiros" (documentada como exemplo em `docs/CONTENT_PIPELINE.md`, sem nenhum conteúdo real ainda).
- Comportamentos especiais de chefe por fase (dash, projéteis, invocação, telegraph visual) — a detecção de fase e o ponto de extensão (`BossEnemy._on_phase_changed()`) já existem.
- Bestiário próprio (inimigos comuns) — a Coleção já tem abas de Personagens/Skins/Localidades/Bosses/Conquistas, mas não uma de Inimigos.
- Botão físico "voltar" do Android tratado nas telas de Pause/Configurações antigas (as novas telas da Etapa 7 já tratam).
- Arte final substituindo os sprites básicos atuais.
- Balanceamento e ajuste fino de dificuldade e economia de Essência/Fragmentos Míticos.
