import puppeteer from 'puppeteer-core';
import chromium from '@sparticuz/chromium';

/**
 * Generates a PDF from HTML content using Puppeteer.
 * Optimized for Vercel Serverless Functions.
 */
export async function generatePdf(html: string) {
  let browser = null;
  try {
    browser = await puppeteer.launch({
      args: chromium.args,
      executablePath: await chromium.executablePath(),
      headless: true,
      acceptInsecureCerts: true,
    });

    const page = await browser.newPage();
    
    // Set content and wait for it to be fully rendered
    await page.setContent(html, { 
      waitUntil: ['networkidle0', 'load', 'domcontentloaded'],
      timeout: 30000 
    });

    // Generate PDF
    const pdf = await page.pdf({
      format: 'A4',
      printBackground: true,
      margin: {
        top: '40px',
        bottom: '40px',
        left: '40px',
        right: '40px'
      },
      displayHeaderFooter: true,
      headerTemplate: '<div></div>',
      footerTemplate: `
        <div style="font-size: 10px; width: 100%; text-align: center; color: #999; font-family: sans-serif;">
          Page <span class="pageNumber"></span> of <span class="totalPages"></span>
        </div>
      `,
    });

    return pdf;
  } catch (error) {
    console.error('Error generating PDF:', error);
    throw createError({
      statusCode: 500,
      statusMessage: 'Failed to generate PDF report',
    });
  } finally {
    if (browser) {
      await browser.close();
    }
  }
}
