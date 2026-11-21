# C.B.J Adventures 2.0

Projeto Godot 4, aventura de plataforma em 8 fases com Ceviche, Bolinha e Januário.

## Escopo implementado nesta entrega
- Oito layouts distintos com personagens definidos pela narrativa.
- Cenários procedurais em múltiplas camadas e paletas próprias.
- Animações experimentais em spritesheet geradas a partir dos sprites originais.
- Inimigos com patrulha, dano, derrota por salto, espinhos, colecionáveis e checkpoints.
- Física com aceleração, pulo duplo, coyote time e jump buffering.
- Música sintetizada original para cada fase e efeitos de ação.
- Salvamento de progresso, contador de sachês, HUD e controles touchscreen.
- Reencontro com dois humanos estilizados ao fim de cada fase, final coletivo e créditos.

## Limitações conhecidas
- As animações são variações procedurais dos sprites existentes, não animações desenhadas individualmente.
- Cenários usam arte procedural geométrica, não cenários de qualidade final ilustrados manualmente.
- Os retratos de Tamires e Mateus foram adaptados da arte conceitual aprovada, criada com base na fotografia enviada. Ainda não são sprites de animação com transparência e quadros independentes.
- Não há chefes com comportamento complexo, cutscenes cinematográficas ou sistema de puzzles avançado.
- Não foi possível testar o projeto no editor Godot nem exportar APK neste ambiente.
- O projeto não deve ser anunciado como finalizado ou validado sem execução no Godot e testes Android.

## Execução
1. Instale Godot 4.3 ou superior.
2. Importe a pasta do projeto, selecionando `project.godot`.
3. Execute a cena principal com F6 ou o projeto com F5.
4. Teclado: A/D ou setas, espaço para pular. Android: controles na tela.

## APK
Instale Godot Android export templates e Android SDK/JDK. Configure o preset Android em Project > Export e exporte APK de debug para testes. Uma versão de distribuição exige assinatura apropriada. A exportação não foi executada nesta entrega.

## Conteúdo original
Os sprites originais e ícones enviados pelo usuário foram mantidos em `assets/cats` e `assets/icons`.

## Atualização de personagens (20/11/2026)
- Retratos em pixel art de **Tamires** e **Mateus** adicionados às cenas de conclusão, com os nomes corretos.
- Créditos finais atualizados com os nomes do casal.
- Checkpoints agora só avançam, evitando que o jogador volte a um checkpoint anterior ao atravessar a fase novamente.
- A folha de personagens aprovada está incluída como referência artística em `docs/character_reference.png`.
- Próxima etapa técnica: importar o projeto no Godot e corrigir quaisquer erros reportados pelo editor antes da exportação Android.
