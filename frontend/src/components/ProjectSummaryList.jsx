import styled from "styled-components";
import { ProjectSummary } from "./ProjectSummary";
import { NavLink } from "react-router-dom";
import { useFetchWithAuth } from "../utils/fetchData";
import { useEffect, useState } from "react";

const StyledList = styled.ul`
  display: flex;
  flex-direction: column;
  gap: 5px;
  justify-content: flex-start;
  max-width: 300px;
`;

const StyledNavLink = styled(NavLink)`
  text-decoration: none;
  color: inherit;
  font-family: inherit;

  &:active {
    font-weight: bold;
    color: #007bff;
  }

  &:hover {
    color: #0056b3;
  }
`;

export function ProjectSummaryList() {
  const [projects, setProjects] = useState([]);
  const [loading, setLoading] = useState(true);
  const fetchWithAuth = useFetchWithAuth();

  useEffect(() => {
    const getProjects = async () => {
      try {
        const res = await fetchWithAuth("/Projects");
        if (res.ok) {
          const data = await res.json();
          setProjects(data);
        }
      } catch (error) {
        console.log("Failed to fetch projects", error);
      } finally {
        setLoading(false);
      }
    };
    getProjects();
  }, []);

  if (loading) return <div>Loading projects...</div>;

  return (
    <>
      <StyledList>
        {projects.map((project) => (
          <StyledNavLink
            key={project.project_id}
            to={`/Projects/${project.project_id}`}
          >
            <ProjectSummary
              key={project.project_id}
              title={project.title}
              author={project.author}
              date={project.create_date}
              comments={project.comments}
              views={project.views}
              likes={project.views}
              saves={project.saves}
              setLike={true}
              setSave={false}
            />
          </StyledNavLink>
        ))}
      </StyledList>
    </>
  );
}
