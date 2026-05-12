const monthlyPrice = 25;
const storeFeeRate = 0.15;
const taxRate = 0.15;

const scenarios = [
  {
    users: 100,
    label: "100 usuários",
    supabaseCost: 123,
    supabaseNote: "Supabase Pro mínimo para produção. O custo fixo pesa mais no começo.",
  },
  {
    users: 1000,
    label: "1.000 usuários",
    supabaseCost: 123,
    supabaseNote: "Supabase Pro ainda deve cobrir o cenário com folga, dependendo do uso.",
  },
  {
    users: 10000,
    label: "10.000 usuários",
    supabaseCost: 300,
    supabaseNote: "Estimativa com Pro e possível ajuste pequeno de compute/egress.",
  },
  {
    users: 100000,
    label: "100.000 usuários",
    supabaseCost: 1750,
    supabaseNote: "Pro + compute Large/XL + excedentes prováveis de egress e disco.",
  },
];

const moneyFormatter = new Intl.NumberFormat("pt-BR", {
  style: "currency",
  currency: "BRL",
  maximumFractionDigits: 0,
});

const refs = {
  heroUsers: document.querySelector("#heroUsers"),
  heroNet: document.querySelector("#heroNet"),
  grossMonth: document.querySelector("#grossMonth"),
  netMonth: document.querySelector("#netMonth"),
  grossYear: document.querySelector("#grossYear"),
  flowGross: document.querySelector("#flowGross"),
  flowStore: document.querySelector("#flowStore"),
  flowSupabase: document.querySelector("#flowSupabase"),
  flowTax: document.querySelector("#flowTax"),
  flowNet: document.querySelector("#flowNet"),
  storeCost: document.querySelector("#storeCost"),
  supabaseCost: document.querySelector("#supabaseCost"),
  supabaseNote: document.querySelector("#supabaseNote"),
  taxCost: document.querySelector("#taxCost"),
  taxNote: document.querySelector("#taxNote"),
  homesText: document.querySelector("#homesText"),
  carsText: document.querySelector("#carsText"),
  teamText: document.querySelector("#teamText"),
  reserveText: document.querySelector("#reserveText"),
  scaleRows: document.querySelector("#scaleRows"),
};

function calculate(users) {
  const scenario = scenarios.find((item) => item.users === users);
  const grossMonth = users * monthlyPrice;
  const storeFee = grossMonth * storeFeeRate;
  const supabaseCost = scenario.supabaseCost;
  const taxCost = grossMonth * taxRate;
  const netMonth = grossMonth - storeFee - taxCost - supabaseCost;
  const grossYear = grossMonth * 12;
  const netYear = netMonth * 12;

  return { users, grossMonth, storeFee, supabaseCost, taxCost, netMonth, grossYear, netYear };
}

function renderScenario(users) {
  const data = calculate(users);
  const scenario = scenarios.find((item) => item.users === users);

  refs.heroUsers.textContent = scenario.label;
  refs.heroNet.textContent = `${formatMoney(data.netMonth)} líquidos após loja, imposto e Supabase`;
  refs.grossMonth.textContent = formatMoney(data.grossMonth);
  refs.netMonth.textContent = formatMoney(data.netMonth);
  refs.grossYear.textContent = formatMoney(data.grossYear);
  refs.flowGross.textContent = formatMoney(data.grossMonth);
  refs.flowStore.textContent = `-${formatMoney(data.storeFee)}`;
  refs.flowSupabase.textContent = `-${formatMoney(data.supabaseCost)}`;
  refs.flowTax.textContent = `-${formatMoney(data.taxCost)}`;
  refs.flowNet.textContent = formatMoney(data.netMonth);
  refs.storeCost.textContent = formatMoney(data.storeFee);
  refs.supabaseCost.textContent = formatMoney(data.supabaseCost);
  refs.supabaseNote.textContent = scenario.supabaseNote;
  refs.taxCost.textContent = formatMoney(data.taxCost);
  refs.taxNote.textContent = `Estimativa de ${taxRate * 100}% sobre a receita bruta. Confirme com contador.`;

  renderBuyingPower(data);
  updateButtons(users);
}

function renderBuyingPower(data) {
  if (data.users === 100) {
    refs.homesText.textContent = "Ainda é fase de validação: paga ferramentas, melhora produto e cria caixa inicial.";
    refs.carsText.textContent = "Não é cenário para luxo; é cenário para provar retenção e aquisição.";
    refs.teamText.textContent = "Dá para bancar apoio pontual, freelancers ou pequenos serviços essenciais.";
    refs.reserveText.textContent = "Começa uma reserva pequena e mostra se a assinatura realmente se sustenta.";
    return;
  }

  if (data.users === 1000) {
    refs.homesText.textContent = "Já vira renda empresarial relevante, mas ainda pede disciplina com retirada.";
    refs.carsText.textContent = "Permite upgrades moderados, sem perder foco em crescimento e suporte.";
    refs.teamText.textContent = "Sustenta uma operação enxuta com suporte, melhoria contínua e aquisição.";
    refs.reserveText.textContent = "Cria caixa para vários meses de produto e marketing controlado.";
    return;
  }

  if (data.users === 10000) {
    refs.homesText.textContent = "Começa a formar patrimônio forte se a operação continuar enxuta.";
    refs.carsText.textContent = "Carros premium ficam possíveis, mas o melhor retorno ainda é reinvestir.";
    refs.teamText.textContent = "Banca um time pequeno e competente de produto, suporte, design e marketing.";
    refs.reserveText.textContent = "Constrói reserva milionária ao longo do ano com gestão séria.";
    return;
  }

  if (data.users === 100000) {
    refs.homesText.textContent = "Compra imóveis de alto padrão com frequência e ainda sobra caixa para reinvestir.";
    refs.carsText.textContent = "Permite carros premium, frota de apoio e upgrades sem comprometer a empresa.";
    refs.teamText.textContent = "Sustenta um time enxuto e forte de tecnologia, suporte, design e marketing.";
    refs.reserveText.textContent = "Forma uma reserva milionária em poucos meses se o gasto for disciplinado.";
    return;
  }

}

function renderTable() {
  refs.scaleRows.innerHTML = scenarios
    .map((scenario) => {
      const data = calculate(scenario.users);
      return `
        <tr>
          <td>${scenario.label}</td>
          <td>${formatMoney(data.grossMonth)}</td>
          <td>-${formatMoney(data.storeFee)}</td>
          <td>-${formatMoney(data.supabaseCost)}</td>
          <td>-${formatMoney(data.taxCost)}</td>
          <td>${formatMoney(data.netMonth)}</td>
          <td>${formatMoney(data.grossYear)}</td>
        </tr>
      `;
    })
    .join("");
}

function updateButtons(users) {
  document.querySelectorAll("[data-users]").forEach((button) => {
    button.classList.toggle("active", Number(button.dataset.users) === users);
  });
}

function formatMoney(value) {
  return moneyFormatter.format(value);
}

document.querySelectorAll("[data-users]").forEach((button) => {
  button.addEventListener("click", () => renderScenario(Number(button.dataset.users)));
});

renderTable();
renderScenario(100);
