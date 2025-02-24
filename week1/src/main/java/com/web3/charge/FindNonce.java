package com.web3.charge;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class FindNonce {

    public static void main(String[] args) {
        String input = "环游星空";
        long nonce = 0;
        String prefixStr = "0000";
        doFindNonce(input, nonce,prefixStr);

        prefixStr = "00000";
        doFindNonce(input, nonce,prefixStr);
    }

    public static String doFindNonce(String input, long nonce,String prefixStr) {
        if(null == prefixStr || "".equals(prefixStr)){
            prefixStr = "00000";
        }
        boolean found = false;
        long startTime = System.currentTimeMillis();

        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");

            while (!found) {
                String data = input + nonce;
                byte[] hashBytes = digest.digest(data.getBytes());

                // 将哈希值转换为十六进制字符串
                StringBuilder hexString = new StringBuilder();
                for (byte b : hashBytes) {
                    String hex = Integer.toHexString(0xff & b);
                    if (hex.length() == 1) hexString.append('0');
                    hexString.append(hex);
                }

                String hashResult = hexString.toString();

                // 检查哈希值是否以4个0开头
                if (hashResult.startsWith(prefixStr)) {
                    found = true;
                    long endTime = System.currentTimeMillis();
                    long elapsedTime = endTime - startTime;

                    System.out.println("prefix str: " + prefixStr);
                    System.out.println("Found nonce: " + nonce);
                    System.out.println("Hash result: " + hashResult);
                    System.out.println("Time elapsed: " + elapsedTime + " ms");
                    System.out.println("--------------------------------------------");
                    return data;
                } else {
                    nonce++;
                }
            }
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        }
        return null;
    }
}