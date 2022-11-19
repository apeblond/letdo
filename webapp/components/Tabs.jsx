import { useState } from "react";

export default function TabsComponent({
  firstElement,
  secondElement,
  thirdElement,
}) {
  const [openTab, setOpenTab] = useState(1);

  return (
    <div>
      <div className="container mx-auto">
        <div className="py-6 justify-center text-center">
          <ul className="flex space-x-2 justify-center">
            <li>
              <a
                href="#"
                onClick={() => setOpenTab(1)}
                className="inline-block px-4 py-2 text-gray-600 bg-white rounded shadow"
              >
                {firstElement.title}
              </a>
            </li>
            <li>
              <a
                href="#"
                onClick={() => setOpenTab(2)}
                className="inline-block px-4 py-2 text-gray-600 bg-white rounded shadow"
              >
                {secondElement.title}
              </a>
            </li>
            <li>
              <a
                href="#"
                onClick={() => setOpenTab(3)}
                className="inline-block px-4 py-2 text-gray-600 bg-white rounded shadow"
              >
                {thirdElement.title}
              </a>
            </li>
          </ul>
          <div className="p-3 mt-6 bg-white border">
            <div className={openTab === 1 ? "block" : "hidden"}>
              {firstElement.component}
            </div>
            <div className={openTab === 2 ? "block" : "hidden"}>
              {secondElement.component}
            </div>
            <div className={openTab === 3 ? "block" : "hidden"}>
              {thirdElement.component}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
