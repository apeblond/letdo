import { useRef, useState } from "react";
import { decryptText } from "../lib/encrypt-decrypt";

const Decrypt = () => {
  const infoRef = useRef(null);
  const [decryptedInfo, setDecryptedInfo] = useState("");

  const decryptInfo = async () => {
    if (infoRef.current.value != "") {
      setDecryptedInfo(await decryptText(infoRef.current.value));
    }
  };

  const onDecrypt = () => {
    decryptInfo();
  };
  return (
    <div className="w-full max-w-xs">
      <div className="mb-4">
        <label
          className="block text-gray-700 text-sm font-bold mb-2"
          htmlFor="info"
        >
          Delivery Info To Decrypt
        </label>
        <textarea
          ref={infoRef}
          id="info"
          rows="4"
          className="block p-2.5 w-full text-sm text-gray-900 bg-gray-50 rounded-lg border focus:ring-blue-500"
          placeholder="Enter the delivery info from the order to be decrypted"
        />
      </div>

      <div className="flex items-center justify-between">
        <button
          className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
          type="button"
          onClick={onDecrypt}
        >
          Decrypt
        </button>
      </div>

      {decryptedInfo ? (
        <div className="flex items-center justify-between">
          <div className="mb-4">
            <label
              className="block text-gray-700 text-sm font-bold mb-2"
              htmlFor="info"
            >
              Decrypted Info
            </label>
            <p className="overflow-x-auto break-all">{decryptedInfo}</p>
          </div>
        </div>
      ) : (
        ""
      )}
    </div>
  );
};

export default Decrypt;
