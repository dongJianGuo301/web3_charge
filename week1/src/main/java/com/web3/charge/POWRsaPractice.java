package com.web3.charge;

import java.security.*;
import java.util.Base64;


/**
 * @Auther dongjg
 * @Description TODO
 * @since 2025/2/24 21:28
 */
public class POWRsaPractice {
    public static void main(String[] args) {
        String input = "环游星空";
        long nonce = 0;
        String prefixStr = "0000";
        String data = FindNonce.doFindNonce(input, nonce, prefixStr);
        System.out.println(data);
        try {
            // 1. 生成RSA密钥对
            KeyPair keyPair = generateKeyPair();

            // 2. 获取公钥和私钥
            PublicKey publicKey = keyPair.getPublic();
            PrivateKey privateKey = keyPair.getPrivate();

            // 3. 待签名的数据
            System.out.println("原始数据: " + data);

            // 4. 使用私钥对数据进行签名
            String signature = sign(data, privateKey);
            System.out.println("签名结果: " + signature);

            // 5. 使用公钥验证签名
            boolean isValid = verify(data, signature, publicKey);
            System.out.println("签名验证结果: " + isValid);
        }catch (Exception e){
            e.printStackTrace();
        }
    }

        /**
         * 生成RSA密钥对
         */
        public static KeyPair generateKeyPair() throws NoSuchAlgorithmException {
            KeyPairGenerator keyPairGenerator = KeyPairGenerator.getInstance("RSA");
            keyPairGenerator.initialize(2048); // 密钥长度为2048位
            return keyPairGenerator.generateKeyPair();
        }

        /**
         * 使用私钥对数据进行签名
         */
        public static String sign(String data, PrivateKey privateKey) throws Exception {
            // 创建Signature对象
            Signature signature = Signature.getInstance("SHA256withRSA");
            signature.initSign(privateKey);

            // 更新要签名的数据
            signature.update(data.getBytes());

            // 生成签名
            byte[] signBytes = signature.sign();

            // 将签名转换为Base64编码的字符串
            return Base64.getEncoder().encodeToString(signBytes);
        }

        /**
         * 使用公钥验证签名
         */
        public static boolean verify(String data, String signature, PublicKey publicKey) throws Exception {
            // 创建Signature对象
            Signature verifySignature = Signature.getInstance("SHA256withRSA");
            verifySignature.initVerify(publicKey);

            // 更新要验证的数据
            verifySignature.update(data.getBytes());

            // 将Base64编码的签名转换为字节数组
            byte[] signBytes = Base64.getDecoder().decode(signature);

            // 验证签名
            return verifySignature.verify(signBytes);
        }

    }
