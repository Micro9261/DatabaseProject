import React, { useState, useEffect } from "react";
import styled from "styled-components";
import { Header } from "../components/Header";
import { useFetchWithAuth } from "../utils/fetchData";
import { Trash } from "lucide-react";

const StatsContainer = styled.div`
  display: flex;
  flex-direction: column;
  height: 100vh;
  background-color: #f4f7f6;
`;

const ControlBar = styled.div`
  display: flex;
  justify-content: center;
  gap: 20px;
  padding: 20px;
  background-color: white;
  border-bottom: 1px solid #ddd;
`;

const TabButton = styled.button`
  padding: 10px 30px;
  font-weight: bold;
  cursor: pointer;
  border: 2px solid rgb(29, 192, 221);
  background-color: ${(props) =>
    props.$active ? "rgb(29, 192, 221)" : "white"};
  color: ${(props) => (props.$active ? "white" : "rgb(29, 192, 221)")};
  border-radius: 5px;
  transition: all 0.2s;

  &:hover {
    background-color: rgb(29, 192, 221);
    color: white;
  }
`;

const ScrollPanel = styled.div`
  flex: 1;
  overflow: auto;
  padding: 20px;
  margin: 10px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
`;

// const StyledTable = styled.table`
//   width: 100%;
//   border-collapse: collapse;
//   min-width: 800px;

//   th {
//     position: sticky;
//     top: 0;
//     background-color: rgb(10, 158, 42);
//     color: white;
//     padding: 12px;
//     text-align: left;
//     z-index: 10;
//   }

//   td {
//     padding: 10px;
//     border-bottom: 1px solid #eee;
//     font-size: 0.9rem;
//   }

//   tr:hover {
//     background-color: #f9f9f9;
//   }
// `;

const StyledTable = styled.table`
  width: 100%;
  /* Important: use 'collapse' so borders from adjacent cells merge into one */
  border-collapse: collapse;
  min-width: 800px;
  background-color: white;

  th {
    position: sticky;
    top: 0;
    background-color: rgb(10, 158, 42);
    color: white;
    padding: 15px 12px;
    text-align: left;
    z-index: 10;
    /* Border for the header cells */
    border: 1px solid rgb(7, 120, 32);
    font-size: 10px;
    font-weight: bold;
  }

  td {
    padding: 12px;
    /* This creates the row and column lines */
    border: 1px solid #d1d1d1;
    font-size: 0.9rem;
    color: #333;
    word-break: break-word;
  }

  /* Optional: Alternate row colors (Zebra Striping) for easier reading */
  tr:nth-child(even) {
    background-color: #f2f2f2;
  }

  tr:hover {
    background-color: #a4c0e6; /* Light blue highlight on hover */
  }
`;

export function StatisticsPage() {
  const fetchWithAuth = useFetchWithAuth();
  const [currentTab, setCurrentTab] = useState("users");
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);

  const fetchData = async (type) => {
    setLoading(true);
    setCurrentTab(type);
    let endpoint = "";

    if (type === "users") endpoint = "/users";
    else if (type === "projects") endpoint = "/Projects";
    else if (type === "threads") endpoint = "/Threads";

    try {
      const res = await fetchWithAuth(endpoint);
      if (res.ok) {
        const result = await res.json();
        setData(result);
      }
    } catch (err) {
      console.error("Failed to fetch stats", err);
    } finally {
      setLoading(false);
    }
  };

  // Initial fetch
  useEffect(() => {
    fetchData("users");
  }, []);

  async function handleDeleteUser(id, login) {
    let endpoint = "";
    if (currentTab === "users") endpoint = "/users";
    else if (currentTab === "projects") endpoint = "/Projects";
    else if (currentTab === "threads") endpoint = "/Threads";

    try {
      const res = await fetchWithAuth(`${endpoint}/${id}`, {
        method: "DELETE",
        body: JSON.stringify({ login: login }),
      });
      if (res.ok) {
        // await res.json();
        setData(data.filter((data) => data["id"] != id));
      }
    } catch (err) {
      console.error("Failed to fetch delete", err);
    }
  }

  async function handleDeleteProject(id) {
    alert(`Project ${id}`);
    try {
      const response = await fetchWithAuth(`/Projects/${id}`, {
        method: "DELETE",
      });

      if (response.ok) {
        console.log("Project deleted successfully");
        try {
          const res = await fetchWithAuth("/Projects");
          if (res.ok) {
            const result = await res.json();
            setData(result);
          }
        } catch (err) {
          console.error("Failed to fetch stats", err);
        } finally {
          setLoading(false);
        }
      } else {
        const errorData = await response.json();
        console.log("Failed updating project: ", errorData);
      }
    } catch (err) {
      console.log("Network error updating project", err);
    }
  }

  async function handleDeleteThread(id) {
    alert(`Thread ${id}`);
    try {
      const response = await fetchWithAuth(`/Threads/${id}`, {
        method: "DELETE",
      });

      if (response.ok) {
        console.log("Project deleted successfully");
        try {
          const res = await fetchWithAuth("/Threads");
          if (res.ok) {
            const result = await res.json();
            setData(result);
          }
        } catch (err) {
          console.error("Failed to fetch stats", err);
        } finally {
          setLoading(false);
        }
      } else {
        const errorData = await response.json();
        console.log("Failed updating project: ", errorData);
      }
    } catch (err) {
      console.log("Network error updating project", err);
    }
  }

  const renderTable = () => {
    if (loading) return <p>Ładowanie danych...</p>;
    if (!data || data.length === 0) return <p>Brak danych do wyświetlenia.</p>;

    // Get keys from first object for headers
    const headers = Object.keys(data[0]);

    return (
      <StyledTable>
        <thead>
          <tr>
            {headers.map((key) => (
              <th key={key}>{key.replace("_", " ").toUpperCase()}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {data.map((row, index) => (
            <>
              <tr key={index}>
                {headers.map((key) => (
                  <>
                    <td key={key}>
                      {typeof row[key] === "boolean"
                        ? row[key]
                          ? "Tak"
                          : "Nie"
                        : row[key]}
                    </td>
                  </>
                ))}
                <td>
                  <button
                    onClick={() =>
                      currentTab === "users"
                        ? handleDeleteUser(row["id"], row["login"])
                        : currentTab === "projects"
                          ? handleDeleteProject(row["project_id"])
                          : handleDeleteThread(row["thread_id"])
                    }
                  >
                    <Trash size={12} />
                  </button>
                </td>
              </tr>
            </>
          ))}
        </tbody>
      </StyledTable>
    );
  };

  return (
    <StatsContainer>
      <Header />
      <ControlBar>
        <TabButton
          $active={currentTab === "users"}
          onClick={() => fetchData("users")}
        >
          Użytkownicy
        </TabButton>
        <TabButton
          $active={currentTab === "projects"}
          onClick={() => fetchData("projects")}
        >
          Projekty
        </TabButton>
        <TabButton
          $active={currentTab === "threads"}
          onClick={() => fetchData("threads")}
        >
          Wątki
        </TabButton>
      </ControlBar>
      <ScrollPanel>{renderTable()}</ScrollPanel>
    </StatsContainer>
  );
}
