import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import "./index.css";

import { createBrowserRouter, RouterProvider } from "react-router-dom";
import { MainPage } from "./pages/MainPage";
import { ThreadsPage } from "./pages/ThreadsPage";
import { ThreadPage } from "./pages/ThreadPage";
import { ProjectsPage } from "./pages/ProjectsPage";
import { ProjectPage } from "./pages/ProjectPage";
import { Settings } from "./pages/Settings";
import { Statistics } from "./pages/Statistics";
import { ErrorPage } from "./pages/ErrorPage";

const router = createBrowserRouter([
  {
    path: "/",
    element: <MainPage />,
    errorElement: <ErrorPage />,
  },
  {
    path: "/threads",
    element: <ThreadsPage />,
  },
  {
    path: "/thread",
    element: <ThreadPage />,
  },
  {
    path: "/projects",
    element: <ProjectsPage />,
  },
  {
    path: "/project",
    element: <ProjectPage />,
  },
  {
    path: "/settings",
    element: <Settings />,
  },
  {
    path: "/statistics",
    element: <Statistics />,
  },
]);

createRoot(document.getElementById("root")).render(
  <StrictMode>
    <RouterProvider router={router} />
  </StrictMode>
);
