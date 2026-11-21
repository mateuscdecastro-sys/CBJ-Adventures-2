# C.B.J Adventures 2.0 | Iteração de ambientes

- Corrigido erro de criação de CollisionShape2D nos obstáculos de espinhos (variável indefinida).
- Adicionadas áreas interativas por fase: trampolins na cozinha e final, rajadas de vento no quintal e telhados, esteiras no depósito.
- Adicionadas verificações estáticas para o script de ambientes.
- Não foi possível executar o Godot neste ambiente. Os efeitos precisam de validação real de física, colisões e balanceamento.
- Nenhuma fotografia pessoal original foi adicionada.

## Iteracao: fisica dos ambientes e transicoes
- Vento e esteiras agora exercem deslocamento continuo enquanto o personagem permanece na zona.
- O impulso ambiental e recalculado a cada frame, sem aceleracao residual ao sair.
- Esteiras so influenciam o personagem no chao.
- O mundo para de processar quando a fase e concluida.
- Testes estaticos e smoke test ampliado; execucao no Godot ainda pendente.

## Estabilidade 01 (20/11/2026)
- Corrigido desbloqueio de saida quando o oitavo sache e coletado dentro do portal.
- Mensagens temporarias nao apagam mais mensagens posteriores.
- Verificacoes estaticas executadas localmente; Godot ainda nao foi executado.
