#!/usr/bin/env python
import os
import csv
import zipfile
import StringIO
import sys
import random

# read file line by line and use iterator to yield line by line (saves memory resources)
def read_input(data_file):
    file_handle = open(data_file, 'rb')
    reader = csv.reader(file_handle, delimiter=' ', quoting=csv.QUOTE_NONE)

    for line in reader:
        # split the line into words
        yield line

def build_model(source_file):
  # Builds a Markov model from the list of bigrams
  model = dict()
  
  for tokens in read_input(source_file):
    gram = tokens[0]
    next_token = tokens[1]
    if gram in model:
      model[gram].append(next_token)
    else:
      model[gram] = [next_token]
  
  final_gram = tokens[0]
  if final_gram in model:
    model[final_gram].append(None)
  else:
    model[final_gram] = [None]

  return model

def generate(model, seed=None, max_iterations=10):
  # Generates a list of words from the information in bi-gram model
  # starts the generation with the 2-gram given as seed. 
  # If more than max_iteration iterations are reached, the
  # process is stopped. (This is to prevent infinite loops)
  if seed is None:
    seed = random.choice(model.keys())

  output = []
  output.append(seed) 
  current = seed

  for i in range(max_iterations-1):
    if current in model:
      possible_next_tokens = model[current]
      next_token = random.choice(possible_next_tokens)
      if next_token is None: break
      output.append(next_token)
      current = output[-1]
    else:
      break
  return output

seed = sys.argv[1]
max_words = int(sys.argv[2])
bigram_file = os.path.join(os.sep, 'gpfs', 'gpfsfpo', 'scripts', 'bigram.pre-processed.txt')

model = build_model(bigram_file)
generated = generate(model, seed, max_words)
print ' '.join(generated)
