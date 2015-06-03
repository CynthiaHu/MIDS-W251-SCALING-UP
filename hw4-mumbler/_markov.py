import glob
import os
import csv
import zipfile
import StringIO

# read file line by line and use iterator to yield line by line (saves memory resources)
def read_input(data_file, file_handle):
    zfile = zipfile.ZipFile(file_handle)
    data = StringIO.StringIO(zfile.read(data_file)) 
    reader = csv.reader(data, delimiter='\t', quoting=csv.QUOTE_NONE)

    for line in reader:
        # split the line into words
        yield line

def build_model(data_dir):
    # build a model from the 2-gram data set with number of occurences 
    # across the corpus
    model = dict()

    for name in glob.glob(os.path.join(data_dir, 'googlebooks-eng-all-2gram-20090715-0.csv.zip')):
        base = os.path.basename(name)
        file_name = os.path.splitext(base)[0]

        data_file = file_name
        archive = '.'.join([data_file, 'zip'])
        full_path = ''.join([data_dir, os.sep, archive])
        file_handle = open(full_path, 'rb')
        data = read_input(data_file, file_handle)

        for row in data:
            gram = tuple(row[0].split())
            if gram in model:
                model[gram] = (model[gram][0] + int(row[1]), 0)
            else:
                model[gram] = (int(row[1]), 0)

    w = open("output.csv", "wb")
    pickle.dump(model, w)
    w.close()


# Main phase of the script
if __name__ == "__main__":
    build_model(os.path.join(os.sep,'gpfs', 'gpfsfpo','data','gpfs1'))
