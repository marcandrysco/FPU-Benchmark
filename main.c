#include <stdio.h>
#include <math.h>

#define FLAGS	4
#define OPS	(sizeof(op) / sizeof(op[0]))
#define VALS	5
#define RUNS	1000
#define DROP	(RUNS/10)

void cpuid(unsigned long, char *);
int runtest(int, int, double, double);

const char *flags[] = {
	"none",
	"ftz",
	"daz",
	"ftz+daz",
};

const char *op[] = {
	"noop",
	"fadd",
	"fmul",
	"fdiv",
	"addsd",
	"mulsd",
	"divsd",
	"addpd",
	"mulpd",
	"divpd",
	"addss",
	"mulss",
	"divss",
	"addps",
	"mulps",
	"divps",
};

const char *type[] = {
	"zero",
	"num",
	"subs",
	"subd",
	"inf",
	"nan"
};

double val[] = {
	0.0,
	1.2,
	1e-42,
	1e-320,
	INFINITY,
	NAN
};

static int sort(const void *left, const void *right)
{
	if(*(const unsigned int *)left > *(const unsigned int *)right)
		return -1;
	else if(*(const unsigned int *)left < *(const unsigned int *)right)
		return 1;
	else
		return 0;
}

int main()
{
	char buf[128], *cpu;
	int r, i, j, k, l;
	int res[FLAGS][OPS][VALS][VALS][RUNS];

	cpuid(0x80000002, buf);
	cpuid(0x80000003, buf + 16);
	cpuid(0x80000004, buf + 32);

	cpu = buf;
	while(*cpu == ' ')
		cpu++;

	for(r = 0; r < RUNS; r++) {
		for(i = 0; i < FLAGS; i++) {
			for(j = 0; j < OPS; j++) {
				for(k = 0; k < VALS; k++) {
					for(l = 0; l < VALS; l++) {
						res[i][j][k][l][r] = runtest(i, j, val[k], val[l]);
					}
				}
			}
		}
	}

	for(i = 0; i < FLAGS; i++) {
		for(j = 0; j < OPS; j++) {
			for(k = 0; k < VALS; k++) {
				for(l = 0; l < VALS; l++) {
					unsigned int total = 0;

					qsort(res[i][j][k][l], RUNS - 2 * DROP, sizeof(unsigned int), sort);

					for(r = DROP; r < RUNS - DROP; r++)
						total += res[i][j][k][l][r];

					res[i][j][k][l][0] = total;
				}
			}
		}
	}

	for(i = 0; i < FLAGS; i++) {
		for(j = 0; j < OPS; j++) {
			if(i > 0 && j < 4)
				continue;

			for(k = 0; k < VALS; k++) {
				for(l = 0; l < VALS; l++) {
					if(j == 0 && (k != 0 || l != 0))
						continue;

					printf("%s\t%s\t%s\t%s\t%s\t%u\n", cpu, flags[i], op[j], type[k], type[l], res[i][j][k][l][0]);
				}
			}
		}
	}

	return 0;
}
