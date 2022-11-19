import { encrypt } from "@metamask/eth-sig-util";
import { Buffer } from "buffer";
import { ethers } from "ethers";

const getPubKey = async () => {
  await window.ethereum.enable();
  const accounts = await window.ethereum.request({
    method: "eth_requestAccounts",
  });
  let encryptionPublicKey;

  await ethereum
    .request({
      method: "eth_getEncryptionPublicKey",
      params: [accounts[0]], // you must have access to the specified account
    })
    .then((result) => {
      encryptionPublicKey = result;
    })
    .catch((error) => {
      if (error.code === 4001) {
        // EIP-1193 userRejectedRequest error
        console.log("We can't encrypt anything without the key.");
      } else {
        console.error(error);
      }
    });

  console.log("getPubKey", encryptionPublicKey);
  return encryptionPublicKey;
};

const encryptText = async (text, publicKey) => {
  function stringifiableToHex(value) {
    return ethers.utils.hexlify(Buffer.from(JSON.stringify(value)));
  }

  return stringifiableToHex(
    encrypt({ publicKey, data: text, version: "x25519-xsalsa20-poly1305" })
  );
};

const decryptText = async (text) => {
  const decryptedText = await ethereum.request({
    method: "eth_decrypt",
    params: [text, ethereum.selectedAddress],
  });

  return decryptedText;
};

export { getPubKey, encryptText, decryptText };
