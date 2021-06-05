package telemo.algos;

public class Fibonacci {
    public static final long fibo(long x){
        if (x <= 1L) return x;
        else return fibo(x-1) + fibo(x-2);
    }

    public static void main(String[] args) {
        System.out.println(fibo(100L));
    }
}
