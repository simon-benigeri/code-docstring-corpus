
#! /bin/sh

# Insert paths to tools
MOSES=../../mosesdecoder
BPE=../../subword-nmt
NEMATUS=../../nematus

cat data_ps.descriptions.test  | iconv -c --from UTF-8 --to UTF-8 | $MOSES/scripts/tokenizer/tokenizer.perl > data_ps.desc2declbodies.test.tok.d
cat data_ps.descriptions.valid | iconv -c --from UTF-8 --to UTF-8 | $MOSES/scripts/tokenizer/tokenizer.perl > data_ps.desc2declbodies.valid.tok.d
cat data_ps.descriptions.train | iconv -c --from UTF-8 --to UTF-8 | $MOSES/scripts/tokenizer/tokenizer.perl > data_ps.desc2declbodies.train.tok.d

cat data_ps.declbodies.test | iconv -c --from UTF-8 --to UTF-8  | $MOSES/scripts/tokenizer/tokenizer.perl > data_ps.desc2declbodies.test.tok.db
cat data_ps.declbodies.valid | iconv -c --from UTF-8 --to UTF-8 | $MOSES/scripts/tokenizer/tokenizer.perl > data_ps.desc2declbodies.valid.tok.db
cat data_ps.declbodies.train | iconv -c --from UTF-8 --to UTF-8 | $MOSES/scripts/tokenizer/tokenizer.perl > data_ps.desc2declbodies.train.tok.db

$MOSES/scripts/training/clean-corpus-n.perl data_ps.desc2declbodies.train.tok d db data_ps.desc2declbodies.train.tok.clean 2 400

cat data_ps.desc2declbodies.train.tok.clean.d data_ps.desc2declbodies.train.tok.clean.db > data_ps.desc2declbodies.train.tok.clean.merged
$BPE/learn_bpe.py -s 89500 < data_ps.desc2declbodies.train.tok.clean.merged > data_ps.desc2declbodies.digram.model

$BPE/apply_bpe.py -c data_ps.desc2declbodies.digram.model < data_ps.desc2declbodies.train.tok.clean.d > data_ps.desc2declbodies.train.bpe.clean.d
$BPE/apply_bpe.py -c data_ps.desc2declbodies.digram.model < data_ps.desc2declbodies.train.tok.clean.db > data_ps.desc2declbodies.train.bpe.clean.db
$BPE/apply_bpe.py -c data_ps.desc2declbodies.digram.model < data_ps.desc2declbodies.valid.tok.d > data_ps.desc2declbodies.valid.bpe.d
$BPE/apply_bpe.py -c data_ps.desc2declbodies.digram.model < data_ps.desc2declbodies.valid.tok.db > data_ps.desc2declbodies.valid.bpe.db
$BPE/apply_bpe.py -c data_ps.desc2declbodies.digram.model < data_ps.desc2declbodies.test.tok.d > data_ps.desc2declbodies.test.bpe.d

cat data_ps.desc2declbodies.train.bpe.clean.db data_ps.desc2declbodies.train.bpe.clean.d > data_ps.desc2declbodies.train.bpe.clean.merged
$NEMATUS/data/build_dictionary.py data_ps.desc2declbodies.train.bpe.clean.merged
