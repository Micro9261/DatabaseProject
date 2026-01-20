import styled from "styled-components";
import { Link, useNavigate } from "react-router-dom";
import { Settings } from "lucide-react";
import { useAuth } from "../Context/AuthContext";
import { useFetchWithAuth } from "../utils/fetchData";

const NavSection = styled.nav`
  display: flex;
  flex-direction: row;
  justify-content: center;
  flex-shrink: 0;
  gap: 60px;
  background-color: rgba(16, 231, 238, 0.938);

  border-bottom: 2px solid rgb(10, 158, 42);
  border-top: 2px solid rgb(10, 158, 42);
  height: 60px;
`;

const HeaderSection = styled.div`
  display: flex;
  flex-direction: row;
  justify-content: flex-end;
  gap: 20px;
  flex-shrink: 0;
  background-color: white;
`;

const StyledNavButtons = styled(Link)`
  display: flex;
  align-items: center;
  justify-content: center;
  border: 1px solid rgb(21, 24, 202);
  border-radius: 20%;
  width: 150px;
  text-decoration: none;
  height: 40px;
  background-color: rgb(29, 192, 221);
  margin-top: 10px;
  font-size: medium;
  color: white;

  &:hover {
    background-color: white;
    color: rgb(29, 192, 221);
  }
`;

const StyledOptButton = styled(Link)`
  display: flex;
  align-items: center;
  justify-content: center;
  text-decoration: none;
  border: 1px solid black;
  border-radius: 10%;
  width: 120px;
  height: 30px;
  background-color: rgb(29, 192, 221);
  margin: 5px;
  font-size: medium;
  color: white;

  &:hover {
    background-color: white;
    color: rgb(29, 192, 221);
  }
`;

export function Header() {
  const { getUserData, logout } = useAuth();
  const { login, role } = getUserData();
  const navigate = useNavigate();
  // console.log("user login, role", login, role);

  const fetchWithAuth = useFetchWithAuth();
  async function handleLogout() {
    const res = await fetchWithAuth("/users/logout", {
      method: "POST",
    });
    if (!res.ok) {
      console.log("Error with response");
      return;
    }
    logout();
    navigate("/");
  }

  return (
    <>
      <HeaderSection>
        {login && <p>{login}</p>}
        <StyledOptButton to={"/options"}>
          <Settings size={24} />
        </StyledOptButton>
        {login ? (
          <StyledOptButton onClick={() => handleLogout()}>
            Wyloguj
          </StyledOptButton>
        ) : (
          <StyledOptButton to={"/login"}>Zaloguj</StyledOptButton>
        )}
      </HeaderSection>
      <NavSection>
        <StyledNavButtons to={"/"}>Strona Główna</StyledNavButtons>
        <StyledNavButtons to={"/Projects"}>Projekty</StyledNavButtons>
        <StyledNavButtons to={"/Threads"}>Wątki</StyledNavButtons>
        {(role == "admin" || role == "moderator") && (
          <StyledNavButtons to={"/Statistics"}>Statystyki</StyledNavButtons>
        )}
      </NavSection>
    </>
  );
}
