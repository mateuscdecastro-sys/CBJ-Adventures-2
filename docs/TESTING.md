# Como testar o projeto

## Teste automático no GitHub

Ao publicar os arquivos descompactados na raiz do repositório, o workflow `.github/workflows/godot-ci.yml` importa o projeto no Godot 4.3 e executa `tests/smoke_test.gd`. Um indicador verde significa apenas que os testes básicos passaram, não que todas as fases foram jogadas manualmente.

## Teste local

1. Instale Godot 4.3 ou versão compatível.
2. Abra `project.godot` no editor.
3. Execute a cena principal com F6 ou o projeto com F5.
4. Use A/D ou setas para mover, Espaço para pular, Esc ou P para pausar. No celular, use os botões na tela.
5. Verifique as oito fases, os checkpoints, a troca automática de gatos na fase final e os créditos.

## Segurança e privacidade

O repositório público deve conter apenas sprites e outros recursos autorizados para publicação. Não envie fotografias originais, senhas ou chaves de assinatura do Android.

## Limitações atuais

A compilação Android e a jogabilidade completa ainda não foram validadas. O teste automático cobre inicialização, personagens, objetivos e pausa, mas não substitui testes em dispositivo real.

## Atualização: objetivo mínimo por fase

Cada fase agora exige coletar pelo menos oito sachês (oito objetos, não oito pontos, pois sachês raros valem cinco pontos). A saída informa quantos faltam. A pontuação total permanece acumulada no arquivo de salvamento. O smoke test verifica que não é possível completar a fase sem a coleta mínima.

## Estado da validação

As mudanças foram verificadas estaticamente, mas **não foram executadas no Godot neste ambiente**: não há binário Godot disponível e a tentativa de obter o Godot 4.3 falhou por indisponibilidade de rede. Executar o workflow de CI antes de considerar a versão aprovada.

## Atualização: feedback visual e checkpoints

A saída começa cinza e marcada como trancada. Após coletar oito objetos, fica verde e exibe "SAÍDA ABERTA". Um aviso confirma a liberação. Ao ativar um checkpoint, a bandeira correspondente fica dourada e aparece um aviso. O smoke test também verifica os estados visuais da saída.
