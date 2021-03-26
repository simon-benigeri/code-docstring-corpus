#!/bin/bash

# Insert paths to nematus
NEMATUS=../../nematus


$NEMATUS/nematus/nmt.py \
  --model data_ps.desc2declbodies.model.npz \
  --datasets data_ps.desc2declbodies.train.bpe.clean.d data_ps.desc2declbodies.train.bpe.clean.db \
  --valid_datasets data_ps.desc2declbodies.valid.bpe.d data_ps.desc2declbodies.valid.bpe.db \
  --dictionaries data_ps.desc2declbodies.train.bpe.clean.merged.json data_ps.desc2declbodies.train.bpe.clean.merged.json \
  --dim_word 400 \
  --dim 800 \
  --n_words_src 89500 \
  --n_words 89500 \
  --maxlen 300 \
  --batch_size 20 \
  --valid_batch_size 1 \
  --optimizer adam \
  --lrate 0.0001 \
  --validFreq 10000 \
  --dispFreq 1000 \
  --saveFreq=30000 \
  --sampleFreq=10000 \
  --dropout_embedding=0.2 \
  --dropout_hidden=0.2 \
  --dropout_source=0.1 \
  --dropout_target=0.1 \
  --max_epoch=10
  