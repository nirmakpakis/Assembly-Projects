

/*
	PART 2.1: using a simple for loop and temporary variable
			to find the max of an array.
*/
int main() {
	int a[5] = {1, 20, 3, 4, 5};
	int max_val, i;
	//todo
	max_val = a[0];
	for(i = 1; i < 5; i++) {
		if (max_val < a[i]) {
			max_val = a[i];
		}
	}
	return max_val;
}

/*
	PART 2.2: using the max_2 ARM subroutine to find the max
			of an array.
*/
extern int max_2(int x, int y);

int main() {
	int a[5] = {1, 20, 3, 4, 5};
	int i;
	int maxVal = a[0];
	for(i = 1; i < 5; i++) {
		maxVal = max_2(maxVal, a[i]);
	}
	return maxVal;
}
