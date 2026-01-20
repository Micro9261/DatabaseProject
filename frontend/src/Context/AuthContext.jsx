import { createContext, useContext, useState } from "react";

const AuthContext = createContext(null);

export const AuthProvider = ({ children }) => {
  const [accessToken, setAccessToken] = useState(null);
  const [role, setRole] = useState(null);
  const [login, setLogin] = useState(null);

  const logout = () => {
    setAccessToken(null);
    setRole(null);
    setLogin(null);
  };

  const getUserData = () => {
    return { role, login };
  };

  const setUserData = (login, role) => {
    setRole(role);
    setLogin(login);
  };

  return (
    <AuthContext.Provider
      value={{ accessToken, setAccessToken, logout, getUserData, setUserData }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);
