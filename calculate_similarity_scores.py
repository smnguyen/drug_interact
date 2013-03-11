#!/usr/bin/env python

import itertools

def main():
	data = {}
	f = open('matrix.txt')
	for line in f:
		line_info = line.split()
		if len(line_info) != 2:	continue

		categories = set(line_info[1].split(','))
		data[line_info[0]] = categories
	f.close()

	f = open('scores.txt', 'w')
	for id1, id2 in itertools.combinations(data, 2):
		intersection = data[id1] & data[id2]
		if len(intersection) == 0: continue

		union = data[id1] | data[id2]
		score = float(len(intersection)) / len(union)
		total_id = ','.join([id1, id2])
		f.write("%s\t%f\n" % (total_id, score))
	f.close()


if __name__ == '__main__':
	main()