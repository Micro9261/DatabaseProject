import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import "./index.css";
import { MainPage } from "./pages/MainPage";
import { createBrowserRouter, RouterProvider } from "react-router-dom";
import { ProjectPage } from "./pages/ProjectPage";
import { ProjectsPage } from "./pages/ProjectsPage";
import { ThreadsPage } from "./pages/ThreadsPage";
import { ThreadPage } from "./pages/ThreadPage";
import { registerAction, RegisterPage } from "./pages/RegisterPage";
import { loginAction, LoginPage } from "./pages/LoginPage";
import { StatisticsPage } from "./pages/Statistics";
import { SettingsPage } from "./pages/Settings";
import { AuthProvider } from "./Context/AuthContext";

const router = createBrowserRouter([
  {
    path: "/",
    element: <MainPage />,
  },
  {
    path: "/Projects",
    element: <ProjectsPage />,
    children: [
      { index: true, element: <div>index</div> },
      {
        path: "/Projects/:ProjectId",
        element: <ProjectPage />,
      },
    ],
  },
  {
    path: "/Threads",
    element: <ThreadsPage />,
    children: [
      { index: true, element: <div>index</div> },
      {
        path: "/Threads/:ThreadsId",
        element: <ThreadPage />,
      },
    ],
  },
  {
    path: "/Login",
    element: <LoginPage />,
    action: loginAction,
  },
  {
    path: "/Register",
    element: <RegisterPage />,
    action: registerAction,
  },
  {
    path: "/Statistics",
    element: <StatisticsPage />,
  },
  {
    path: "/Settings",
    element: <SettingsPage />,
  },
]);

createRoot(document.getElementById("root")).render(
  <StrictMode>
    <AuthProvider>
      <RouterProvider router={router} />
    </AuthProvider>
  </StrictMode>,
);
