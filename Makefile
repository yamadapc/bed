build: FORCE
	dub build

test: FORCE
	dub test

examples: FORCE
	dub -c=examples --build=unittest

FORCE:
