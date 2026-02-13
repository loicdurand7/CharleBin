describe("CharleBin - Create and retrieve paste", () => {

  const message = "Test Cypress CharleBin";
  const password = "monMotDePasse123";

  it("should create a paste, open it and decrypt it", () => {

    cy.visit("http://localhost:8080");

    cy.contains("New").click();

    cy.get("#message").type(message);
    cy.get("#passwordinput").type(password);
    cy.get("#sendbutton").click();

    cy.location("href").then((url) => {

      cy.visit(url);

      cy.get("#passworddecrypt").type(password, { force: true });

      cy.contains("Decrypt").click({ force: true });

      cy.contains(message).should("be.visible");

    });

  });

});
